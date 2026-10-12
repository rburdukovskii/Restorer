require "test_helper"

class ImageProcessorTest < ActiveSupport::TestCase
  def setup
    @source = Rails.root.join("test/fixtures/files/demo.jpg").to_s
  end

  test "apply_filter для original возвращает файл" do
    processor = ImageProcessor.new(@source)
    result = processor.apply_filter("original")

    assert result.is_a?(File)
    assert File.exist?(result.path)
  ensure
    result&.close
  end

  test "apply_filter для bw возвращает обработанный файл" do
    processor = ImageProcessor.new(@source)
    result = processor.apply_filter("bw")

    assert result.is_a?(File)
    assert result.size > 0
  ensure
    result&.close
  end

  test "apply_filter с неизвестным фильтром бросает Error" do
    processor = ImageProcessor.new(@source)
    assert_raises(ImageProcessor::Error) do
      processor.apply_filter("nonexistent")
    end
  end

  test "apply_filter работает для всех фильтров" do
    Filter.all.each_key do |slug|
      processor = ImageProcessor.new(@source)
      result = processor.apply_filter(slug)
      assert File.exist?(result.path), "Фильтр #{slug} не сработал"
      result.close
    end
  end
end