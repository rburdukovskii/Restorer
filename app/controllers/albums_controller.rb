class AlbumsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_album, only: [:show, :edit, :update, :destroy, :add_upload, :remove_upload, :bulk_add_uploads, :bulk_remove_uploads, :add_collaborator, :remove_collaborator]
  before_action :authorize_edit!, only: [:edit, :update, :add_upload, :remove_upload, :bulk_add_uploads, :bulk_remove_uploads]
  before_action :authorize_owner!, only: [:destroy, :add_collaborator, :remove_collaborator]

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
    upload = @album.uploads.find(params[:upload_id])
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

  def bulk_remove_uploads
    upload_ids = Array(params[:upload_ids]).map(&:to_i).reject(&:zero?)

    if upload_ids.empty?
      return redirect_to album_path(@album), alert: "Не выбрано ни одного фото"
    end

    uploads = @album.uploads.where(id: upload_ids)
    count = uploads.count

    # Удаляем только связи (фото остаются в галерее владельца)
    @album.uploads.delete(uploads)

    # Редирект обновит страницу, пересчитает количество фото и обновит сетку
    redirect_to album_path(@album), notice: "Убрано из альбома: #{count}"
  end

  def add_collaborator
    query = params[:query].to_s.strip
    role = params[:role] || "editor"

    if query.blank?
      return redirect_to album_path(@album), alert: "Введите email или имя пользователя"
    end

    user = User.where("email = ? OR name = ?", query, query).where.not(id: current_user.id).first

    if user.nil?
      return redirect_to album_path(@album), alert: "Пользователь не найден"
    end

    collaborator = @album.album_collaborators.build(user: user, role: role, invited_by: current_user)

    if collaborator.save
      redirect_to album_path(@album), notice: "Соавтор добавлен"
    else
      redirect_to album_path(@album), alert: collaborator.errors.full_messages.join(", ")
    end
  end

  def remove_collaborator
    collaborator = @album.album_collaborators.find(params[:collaborator_id])
    collaborator.destroy
    redirect_to album_path(@album), notice: "Соавтор удалён"
  end

  private

  def set_album
    @album = Album.left_joins(:album_collaborators)
                  .where("albums.user_id = ? OR album_collaborators.user_id = ?", current_user.id, current_user.id)
                  .distinct
                  .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to gallery_path, alert: "Альбом не найден"
  end

  def authorize_edit!
    unless @album.editable_by?(current_user)
      redirect_to album_path(@album), alert: "У вас нет прав для редактирования"
    end
  end

  def authorize_owner!
    unless @album.owner?(current_user)
      redirect_to album_path(@album), alert: "Только владелец может выполнять это действие"
    end
  end

  def album_params
    params.require(:album).permit(:name, :description, :cover)
  end
end