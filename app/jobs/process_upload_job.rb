class ProcessUploadJob < ApplicationJob
  queue_as :default

  def perform(upload_id)
    upload = Upload.find(upload_id)

    update_progress(upload, status: "processing", progress: 20)

    upload.broadcast_prepend_to upload.live_stream,
      target: "gallery_uploads",
      partial: "uploads/card",
      locals: { photo: upload }

    filter_slug = upload.filter_name.presence || Filter.default

    begin
      update_progress(upload, progress: 50)

      # Блочная форма: временный файл удалится сразу после attach,
      # в том числе если attach упадёт.
      ImageProcessor.new(upload.original).apply_filter(filter_slug) do |file|
        upload.processed.attach(
          io: file,
          filename: "processed_#{upload.id}.jpg",
          content_type: "image/jpeg"
        )
      end

      update_progress(upload, status: "completed", progress: 100)

      upload.broadcast_replace_to upload.live_stream,
        target: "upload_card_#{upload.id}",
        partial: "uploads/card",
        locals: { photo: upload }

      upload.broadcast_replace_to upload.live_stream,
        target: "upload_show_progress_#{upload.id}",
        partial: "uploads/show_result",
        locals: { upload: upload }

      upload.broadcast_replace_to upload.live_stream,
        target: "upload_download_#{upload.id}",
        partial: "uploads/download_button",
        locals: { upload: upload }

      share_link = ShareLink.find_or_create_active!(
        user: upload.user,
        shareable: upload
      )

      upload.broadcast_replace_to upload.live_stream,
        target: "upload_share_link_#{upload.id}",
        partial: "uploads/share_link",
        locals: { upload: upload, share_link: share_link }

    rescue ImageProcessor::Error => e
      Rails.logger.error("Filter error: #{e.message}")
      mark_failed(upload)
    rescue StandardError => e
      # раньше такое исключение оставляло фото в статусе "processing" навсегда
      Rails.logger.error("Upload #{upload.id} failed: #{e.class}: #{e.message}")
      mark_failed(upload)
      raise
    end
  end

  private

  def mark_failed(upload)
    update_progress(upload, status: "failed", progress: 0)

    upload.broadcast_replace_to upload.live_stream,
      target: "upload_card_#{upload.id}",
      partial: "uploads/card",
      locals: { photo: upload }
  end

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