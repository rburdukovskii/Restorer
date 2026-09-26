class UploadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_upload, only: [:show, :status]

  def new
    @upload = current_user.uploads.build
  end

  def create
    @upload = current_user.uploads.build(upload_params)
    @upload.status = "pending"
    @upload.progress = 0

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

  private

  def set_upload
    @upload = current_user.uploads.find(params[:id])
  end

  def upload_params
    params.require(:upload).permit(:original)
  end
end