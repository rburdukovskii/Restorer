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
    render json: {
      progress: @upload.progress || 0,
      status: @upload.status,
      redirect_url: (@upload.processed.attached? ? upload_path(@upload) : nil)
    }
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
              filename: "restored_#{@upload.id}.jpg",
              type: attachment.content_type
  end

  private

  def set_upload
    @upload = current_user.uploads.find(params[:id])
  end

  def upload_params
    params.require(:upload).permit(:original)
  end
end