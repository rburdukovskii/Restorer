class TmpFilesCleanupJob < ApplicationJob
  queue_as :default

  def perform(ttl_hours: 6)
    result = TmpFilesCleanup.call(ttl: ttl_hours.hours)

    Rails.logger.info(
      "[TmpFilesCleanup] удалено #{result.removed} файлов, " \
      "освобождено #{(result.bytes.to_f / 1.megabyte).round(1)} МБ"
    )

    result
  end
end