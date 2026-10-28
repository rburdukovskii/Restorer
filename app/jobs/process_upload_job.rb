class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    upload = Upload.find(upload_id)
    
    # 1. Обновляем прогресс и шлем стрим
    update_progress(upload, status: "processing", progress: 20)
    
    # 2. Добавляем карточку в общую ленту (если её там нет)
    upload.broadcast_prepend_to upload.live_stream,
      target: "gallery_uploads",
      partial: "uploads/card",
      locals: { photo: upload }

    filter_slug = upload.filter_name.presence || Filter.default

    begin
      update_progress(upload, progress: 50)

      processor = ImageProcessor.new(upload.original)
      processed_file = processor.apply_filter(filter_slug)

      upload.processed.attach(
        io: processed_file,
        filename: "processed_#{upload.id}.jpg",
        content_type: "image/jpeg"
      )

      update_progress(upload, status: "completed", progress: 100)
      
      # После завершения заменяем карточку на готовую
      upload.broadcast_replace_to upload.live_stream,
        target: "upload_card_#{upload.id}",
        partial: "uploads/card",
        locals: { photo: upload }

      # Обновляем страницу show (если она открыта)
      upload.broadcast_replace_to upload.live_stream,
        target: "upload_show_progress_#{upload.id}",
        partial: "uploads/show_result",
        locals: { upload: upload }
        
    rescue ImageProcessor::Error => e
      Rails.logger.error("Filter error: #{e.message}")
      update_progress(upload, status: "failed", progress: 0)
      
      upload.broadcast_replace_to upload.live_stream,
        target: "upload_card_#{upload.id}",
        partial: "uploads/card",
        locals: { photo: upload }
    end
  end

  private

  def update_progress(upload, status: nil, progress: nil)
    attrs = {}
    attrs[:status]   = status   if status
    attrs[:progress] = progress if progress
    upload.update!(attrs)

    upload.broadcast_replace_to upload.live_stream,
      target: "upload_progress_#{upload.id}",
      partial: "uploads/progress_inline",
      locals: { upload: upload }
  end
end