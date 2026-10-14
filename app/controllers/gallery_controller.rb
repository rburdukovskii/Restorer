class GalleryController < ApplicationController
  before_action :authenticate_user!

  def index
    @uploads = current_user.uploads.recent
    @uploads = @uploads.favorites                 if params[:favorites].present?
    @uploads = @uploads.without_album             if params[:without_album].present?
    @uploads = @uploads.in_album(params[:album])  if params[:album].present?
    @uploads = @uploads.with_tag(params[:tag])    if params[:tag].present?

    # Поиск по названию/описанию
    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      @uploads = @uploads.where("LOWER(title) LIKE ? OR LOWER(description) LIKE ?", q, q)
    end

    # Сортировка
    @uploads = case params[:sort]
               when "oldest" then @uploads.reorder(created_at: :asc)
               when "title"  then @uploads.reorder(title: :asc)
               else               @uploads.reorder(created_at: :desc)
               end

    @uploads = @uploads.page(params[:page]).per(12) if @uploads.respond_to?(:page)

    @albums = current_user.albums.recent
    @tags   = current_user.tags.order(:name)
  end
end