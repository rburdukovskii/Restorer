require "mini_magick"
require "tempfile"
require "fileutils"

class ImageProcessor
  class Error < StandardError; end

  OUTPUT_PREFIX  = "processed_"
  OUTPUT_QUALITY = "92"

  def initialize(image_source)
    @image_source = image_source
  end

  # С блоком — файл гарантированно закрывается и удаляется после блока:
  #
  #   ImageProcessor.new(upload.original).apply_filter("bw") do |file|
  #     upload.processed.attach(io: file, filename: "...", content_type: "image/jpeg")
  #   end
  #
  # Без блока — возвращает File, как раньше (совместимость со старыми тестами);
  # в этом случае закрытие и удаление — ответственность вызывающего.
  def apply_filter(filter_slug)
    filter = Filter.find(filter_slug)
    raise Error, "Unknown filter: #{filter_slug}" unless filter

    file = render(filter)
    return file unless block_given?

    begin
      yield file
    ensure
      discard(file)
    end
  end

  private

  def render(filter)
    FileUtils.mkdir_p(tmp_dir)

    # Tempfile.create (в отличие от Tempfile.new) возвращает обычный File
    # и НЕ удаляет файл по GC — жизненным циклом управляем мы сами.
    output = Tempfile.create([OUTPUT_PREFIX, ".jpg"], tmp_dir)
    output.close

    begin
      with_source do |source_path|
        image = MiniMagick::Image.open(source_path)
        begin
          image.auto_orient # применяем EXIF-поворот ДО strip, иначе фото ляжет набок
          filter[:operations].each { |op| apply_operation(image, op) }
          image.format("jpg")
          image.strip
          image.quality(OUTPUT_QUALITY)
          image.write(output.path)
        ensure
          image.destroy! # удаляет внутренний tempfile MiniMagick, не дожидаясь GC
        end
      end

      File.open(output.path, "rb")
    rescue MiniMagick::Error, MiniMagick::Invalid,
           Errno::ENOENT, Errno::EACCES, Errno::ENOSPC => e
      FileUtils.rm_f(output.path)
      raise Error, "Не удалось обработать изображение: #{e.message}"
    rescue StandardError
      FileUtils.rm_f(output.path)
      raise
    end
  end

  # Отдаёт путь к локальному файлу-источнику и гарантирует уборку за собой.
  def with_source
    source = @image_source

    if source.is_a?(String) || source.is_a?(Pathname)
      yield source.to_s
    elsif source.respond_to?(:path) && source.path.present?
      yield source.path                       # File / Tempfile — не наш, не трогаем
    elsif source.respond_to?(:open)
      source.open { |file| yield file.path }  # ActiveStorage: сам создаст и удалит копию
    elsif source.respond_to?(:download)
      Tempfile.create(["source", ".jpg"], tmp_dir) do |file|
        file.binmode
        file.write(source.download)
        file.flush
        yield file.path                       # файл живёт ровно до конца блока
      end
    else
      raise Error, "Unsupported image source: #{source.class}"
    end
  end

  def discard(file)
    file.close unless file.closed?
    FileUtils.rm_f(file.path)
  end

  def tmp_dir
    Rails.root.join("tmp").to_s
  end

  def apply_operation(image, op)
    case op[:type]
    when :fade
      amount = op[:value] || 20
      image.combine_options do |c|
        c.level("#{amount}%,100%")
      end

    when :colorspace
      image.colorspace(op[:value])

    when :sepia
      image.sepia_tone("#{op[:value]}%")

    when :modulate
      val = op[:value]
      brightness = val[:brightness] || 100
      saturation = val[:saturation] || 100
      hue        = val[:hue] || 100

      image.modulate("#{brightness},#{saturation},#{hue}")

    when :sharpen
      image.sharpen(op[:value])

    when :contrast
      image.combine_options do |c|
        c.sigmoidal_contrast("3x#{op[:value]}%")
      end

    when :colorize
      amount = op[:value][:amount] || 20
      color  = op[:value][:color]
      rgb = color.delete("#").scan(/../).map { |c| c.to_i(16) }
      rgb_color = "rgb(#{rgb.join(",")})"

      image.combine_options do |c|
        c.fill(rgb_color)
        c.colorize("#{amount}%")
      end

    when :resize
      image.resize(op[:value])

    else
      Rails.logger.warn("Unknown operation: #{op[:type]}")
    end
  end
end