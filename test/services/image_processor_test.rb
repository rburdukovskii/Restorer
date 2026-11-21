require "test_helper"

class ImageProcessorTest < ActiveSupport::TestCase
  def setup
    @source = Rails.root.join("test/fixtures/files/demo.jpg").to_s
  end

  test "apply_filter для original возвращает файл" do
    result = ImageProcessor.new(@source).apply_filter("original")

    assert result.is_a?(File)
    assert File.exist?(result.path)
    assert result.size > 0
  ensure
    discard(result)
  end

  test "apply_filter для bw возвращает обработанный файл" do
    result = ImageProcessor.new(@source).apply_filter("bw")

    assert result.is_a?(File)
    assert result.size > 0
  ensure
    discard(result)
  end

  test "apply_filter с неизвестным фильтром бросает Error" do
    assert_raises(ImageProcessor::Error) do
      ImageProcessor.new(@source).apply_filter("nonexistent")
    end
  end

  test "apply_filter работает для всех фильтров" do
    Filter.all.each_key do |slug|
      ImageProcessor.new(@source).apply_filter(slug) do |file|
        assert File.exist?(file.path), "Фильтр #{slug} не сработал"
        assert file.size > 0, "Фильтр #{slug} вернул пустой файл"
      end
    end
  end

  private

  # Форма без блока отдаёт владение файлом вызывающему — убираем сами.
  def discard(file)
    return unless file

    file.close unless file.closed?
    FileUtils.rm_f(file.path)
  end
end