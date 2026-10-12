require "mini_magick"

class ImageProcessor
  class Error < StandardError; end

  def initialize(image_source)
    @image_source = image_source
  end

  def apply_filter(filter_slug)
    filter = Filter.find(filter_slug)
    raise Error, "Unknown filter: #{filter_slug}" unless filter

    return File.open(download_source) if filter[:operations].empty?

    image = MiniMagick::Image.open(download_source)

    filter[:operations].each do |op|
      apply_operation(image, op)
    end

    image.strip
    output_path = Rails.root.join("tmp", "processed_#{SecureRandom.hex(8)}.jpg")
    image.format("jpg")
    image.quality("92")
    image.write(output_path)
    File.open(output_path)
  end

  private

  def download_source
    return @image_source if @image_source.is_a?(String)
    return @image_source.path if @image_source.respond_to?(:path)

    tempfile = Tempfile.new(["source", ".jpg"])
    tempfile.binmode
    tempfile.write(@image_source.download)
    tempfile.rewind
    tempfile.path
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
        args = op[:value].values.map(&:to_s)
        image.modulate(args.join(","))
      when :sharpen
        image.sharpen(op[:value])
      when :contrast
        image.contrast
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