class AlbumsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_album, only: [:show, :edit, :update, :destroy, :add_upload, :remove_upload]

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

  private

  def set_album
    @album = current_user.albums.find(params[:id])
  end

  def album_params
    params.require(:album).permit(:name, :description, :cover)
  end
end