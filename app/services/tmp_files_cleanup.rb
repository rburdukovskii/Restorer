require "tmpdir"
require "fileutils"

class TmpFilesCleanup
  Result = Struct.new(:removed, :bytes, :paths, keyword_init: true)

  TTL = 6.hours

  # каталог => маски. Только те имена, которые создаёт наше приложение.
  # Вложенные каталоги (tmp/storage, tmp/cache/bootsnap) НЕ затрагиваются.
  TARGETS = {
    Rails.root.join("tmp").to_s => %w[processed_*.jpg restored_*.jpg restored_*.png],
    Dir.tmpdir                  => %w[source*.jpg mini_magick*]
  }.freeze

  def self.call(ttl: TTL, dry_run: false, targets: TARGETS)
    new(ttl: ttl, dry_run: dry_run, targets: targets).call
  end

  def initialize(ttl: TTL, dry_run: false, targets: TARGETS)
    @cutoff  = Time.current - ttl
    @dry_run = dry_run
    @targets = targets
  end

  def call
    result = Result.new(removed: 0, bytes: 0, paths: [])

    @targets.each do |dir, patterns|
      patterns.each do |pattern|
        Dir.glob(File.join(dir, pattern)).each do |path|
          next unless File.file?(path)
          next if File.mtime(path) > @cutoff # свежий файл может быть ещё в работе

          size = File.size(path)
          FileUtils.rm_f(path) unless @dry_run

          result.removed += 1
          result.bytes   += size
          result.paths   << path
        rescue Errno::ENOENT
          next # уже удалён другим воркером — не ошибка
        end
      end
    end

    result
  end
end