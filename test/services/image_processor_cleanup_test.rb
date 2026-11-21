require "test_helper"

class ImageProcessorCleanupTest < ActiveSupport::TestCase
  def setup
    @source = Rails.root.join("test/fixtures/files/demo.jpg").to_s
    @glob   = Rails.root.join("tmp", "processed_*.jpg").to_s
  end

  test "блочная форма удаляет файл после использования" do
    path = nil
    ImageProcessor.new(@source).apply_filter("bw") do |file|
      path = file.path
      assert File.exist?(path)
      assert file.size > 0
    end

    assert_not File.exist?(path), "временный файл остался: #{path}"
  end

  test "файл удаляется даже если блок упал" do
    path = nil
    assert_raises(RuntimeError) do
      ImageProcessor.new(@source).apply_filter("sepia") do |file|
        path = file.path
        raise "boom"
      end
    end

    assert_not File.exist?(path)
  end

  test "после обработки в tmp не появляется новых файлов" do
    before = Dir.glob(@glob).sort
    ImageProcessor.new(@source).apply_filter("retro") { |file| file.read(1) }
    assert_equal before, Dir.glob(@glob).sort
  end

  test "ошибка MiniMagick becomes ImageProcessor::Error и не оставляет мусора" do
    before = Dir.glob(@glob).sort
    broken = Rails.root.join("tmp", "broken_source.jpg")
    File.binwrite(broken, "this is not an image")

    assert_raises(ImageProcessor::Error) do
      ImageProcessor.new(broken.to_s).apply_filter("bw") { |file| file.read(1) }
    end

    assert_equal before, Dir.glob(@glob).sort
  ensure
    FileUtils.rm_f(broken)
  end
end