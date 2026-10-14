class AlbumsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_album, only: [:show, :edit, :update, :destroy, :add_upload, :remove_upload, :bulk_add_uploads]

  def new
    @album = current_user.albums.build
  end

  def create
    @album = current_user.albums.build(album_params)

    if @album.save
      redirect_to gallery_path, notice: "Альбом создан"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @album.update(album_params)
      redirect_to album_path(@album), notice: "Альбом обновлён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @album.destroy
    redirect_to gallery_path, notice: "Альбом удалён"
  end

  def add_upload
    upload = current_user.uploads.find(params[:upload_id])
    @album.uploads << upload unless @album.uploads.include?(upload)
    redirect_to album_path(@album), notice: "Фото добавлено"
  end

  def remove_upload
    upload = current_user.uploads.find(params[:upload_id])
    @album.uploads.delete(upload)
    redirect_to album_path(@album), notice: "Фото убрано из альбома"
  end

  def bulk_add_uploads
    upload_ids = Array(params[:upload_ids]).map(&:to_i).reject(&:zero?)

    if upload_ids.empty?
      return render json: { error: "Не выбрано ни одного фото" }, status: :unprocessable_entity
    end

    uploads = current_user.uploads.where(id: upload_ids)
    count = 0

    uploads.each do |upload|
      unless @album.uploads.include?(upload)
        @album.uploads << upload
        count += 1
      end
    end

    render json: { success: true, message: "Добавлено фото: #{count}" }
  end

  private

  def set_album
    @album = current_user.albums.find(params[:id])
  end

  def album_params
    params.require(:album).permit(:name, :description, :cover)
  end
end