class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    upload = Upload.find(upload_id)
    upload.update(status: "processing", progress: 20)

    sleep 2

    upload.processed.attach(upload.original.blob)
    upload.update(status: "completed", progress: 100)
  rescue => e
    upload&.update(status: "failed")
    Rails.logger.error("ProcessUploadJob error: #{e.message}")
  end
end