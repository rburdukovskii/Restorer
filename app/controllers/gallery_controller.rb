class GalleryController < ApplicationController
  before_action :authenticate_user!

  def index
    @uploads = current_user.uploads.recent

    @uploads = @uploads.favorites                 if params[:favorites].present?
    @uploads = @uploads.without_album             if params[:without_album].present?
    @uploads = @uploads.in_album(params[:album])  if params[:album].present?
    @uploads = @uploads.with_tag(params[:tag])    if params[:tag].present?

    if params[:q].present?
      q = params[:q].downcase.strip
      @uploads = @uploads.includes(:tags, :albums).select do |upload|
        upload.title.to_s.downcase.include?(q) ||
        upload.description.to_s.downcase.include?(q) ||
        upload.tags.any? { |tag| tag.name.downcase.include?(q) } ||
        upload.albums.any? { |album| album.name.downcase.include?(q) }
      end
    end

    # Сортировка
    if @uploads.is_a?(Array)
      @uploads = case params[:sort]
                 when "oldest"
                   @uploads.sort_by { |u| u.created_at }
                 when "title"
                   @uploads.sort_by { |u| [u.title.present? ? 0 : 1, u.title.to_s.downcase, -u.created_at.to_i] }
                 else
                   @uploads.sort_by { |u| -u.created_at.to_i }
                 end
    else
      @uploads = case params[:sort]
                 when "oldest"
                   @uploads.reorder(created_at: :asc)
                 when "title"
                   @uploads.to_a.sort_by { |u| [u.title.present? ? 0 : 1, u.title.to_s.downcase, -u.created_at.to_i] }
                 else
                   @uploads.reorder(created_at: :desc)
                 end
    end

    # Пагинация
    if @uploads.is_a?(Array)
      @uploads = Kaminari.paginate_array(@uploads).page(params[:page]).per(12)
    elsif @uploads.respond_to?(:page)
      @uploads = @uploads.page(params[:page]).per(12)
    end

    @albums = current_user.albums.recent
    @tags   = current_user.tags.order(:name)
  end
end