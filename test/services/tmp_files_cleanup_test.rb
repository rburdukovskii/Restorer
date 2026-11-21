require "test_helper"
require "tmpdir"

class TmpFilesCleanupTest < ActiveSupport::TestCase
  test "удаляет только старые файлы по своей маске" do
    Dir.mktmpdir do |dir|
      old     = File.join(dir, "processed_old.jpg")
      fresh   = File.join(dir, "processed_new.jpg")
      foreign = File.join(dir, "important.jpg")
      [old, fresh, foreign].each { |p| File.binwrite(p, "x" * 10) }

      stamp = 2.days.ago.to_time # File.utime не понимает TimeWithZone
      File.utime(stamp, stamp, old)
      File.utime(stamp, stamp, foreign)

      result = TmpFilesCleanup.call(ttl: 6.hours, targets: { dir => %w[processed_*.jpg] })

      assert_equal 1, result.removed
      assert_not File.exist?(old)
      assert File.exist?(fresh),   "свежий файл трогать нельзя"
      assert File.exist?(foreign), "чужой файл трогать нельзя"
    end
  end

  test "dry_run считает, но не удаляет" do
    Dir.mktmpdir do |dir|
      old = File.join(dir, "processed_old.jpg")
      File.binwrite(old, "x" * 10)

      stamp = 2.days.ago.to_time
      File.utime(stamp, stamp, old)

      result = TmpFilesCleanup.call(ttl: 6.hours, dry_run: true,
                                    targets: { dir => %w[processed_*.jpg] })

      assert_equal 1, result.removed
      assert_equal 10, result.bytes
      assert File.exist?(old)
    end
  end
end