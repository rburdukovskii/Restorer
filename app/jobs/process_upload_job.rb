class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    upload = Upload.find(upload_id)
    upload.update(status: "processing", progress: 20)

    filter_slug = upload.filter_name.presence || Filter.default

    begin
      upload.update(progress: 50)

      processor = ImageProcessor.new(upload.original)
      processed_file = processor.apply_filter(filter_slug)

      upload.processed.attach(
        io: processed_file,
        filename: "processed_#{upload.id}.jpg",
        content_type: "image/jpeg"
      )

      upload.update(status: "completed", progress: 100)
    rescue ImageProcessor::Error => e
      Rails.logger.error("Filter error: #{e.message}")
      upload.update(status: "failed", progress: 0)
    end
  end
end