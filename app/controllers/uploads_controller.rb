class UploadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_upload, only: [:show, :status, :destroy, :toggle_favorite, :download]

  def new
    @upload = current_user.uploads.build
  end

  def create
    @upload = current_user.uploads.build(upload_params)
    @upload.status      = "pending"
    @upload.progress    = 0
    @upload.filter_name = params[:upload][:filter_name].presence || Filter.default

    if params[:upload][:filter_params].present?
      @upload.filter_params = {
        "mode" => params[:upload][:filter_params][:mode]
      }
    end

    if @upload.save
      ProcessUploadJob.perform_later(@upload.id)
      redirect_to @upload, notice: "Фото загружено. Обрабатываем..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def status
    response = {
      progress:     @upload.progress || 0,
      status:       @upload.status,
      redirect_url: (@upload.processed.attached? ? upload_path(@upload) : nil)
    }

    if @upload.status == "failed"
      response[:message] = "Обработка не удалась"
    end

    render json: response
  end

  def destroy
    @upload.destroy
    redirect_to gallery_path, notice: "Фото удалено"
  end

  def toggle_favorite
    @upload.update(favorite: !@upload.favorite)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: gallery_path }
    end
  end

  def download
    attachment = @upload.processed.attached? ? @upload.processed : @upload.original
    send_data attachment.download,
              filename: "processed_#{@upload.id}.jpg",
              type: attachment.content_type
  end

  def bulk_destroy
    ids = params[:upload_ids] || []
    ids = Array(ids).map(&:to_i).reject(&:zero?)

    if ids.empty?
      redirect_to gallery_path, alert: "Ничего не выбрано"
      return
    end

    uploads = current_user.uploads.where(id: ids)
    count = uploads.count

    uploads.each(&:destroy)

    redirect_to gallery_path, notice: "Удалено фото: #{count}"
  end

  def bulk_add_to_album
    upload_ids = Array(params[:upload_ids]).map(&:to_i).reject(&:zero?)

    if upload_ids.empty?
      return render json: { error: "Не выбрано ни одного фото" }, status: :unprocessable_entity
    end

    if params[:new_album_name].present?
      album = current_user.albums.create!(name: params[:new_album_name].strip)
    elsif params[:album_id].present?
      album = current_user.albums.find_by(id: params[:album_id])
    end

    unless album
      return render json: { error: "Альбом не выбран" }, status: :unprocessable_entity
    end

    uploads = current_user.uploads.where(id: upload_ids)
    count = 0

    uploads.each do |upload|
      unless upload.albums.include?(album)
        upload.albums << album
        count += 1
      end
    end

    render json: {
      success: true,
      message: "Добавлено фото: #{count}",
      album_id: album.id,
      album_name: album.name
  }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
end

  private

  def set_upload
    @upload = current_user.uploads.find(params[:id])
  end

  def upload_params
    params.require(:upload).permit(:original)
  end
end