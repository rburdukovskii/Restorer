class GalleryController < ApplicationController
  before_action :authenticate_user!

  def index
    @uploads = current_user.uploads.recent
    @uploads = @uploads.favorites                 if params[:favorites].present?
    @uploads = @uploads.without_album             if params[:without_album].present?
    @uploads = @uploads.in_album(params[:album])  if params[:album].present?
    @uploads = @uploads.with_tag(params[:tag])    if params[:tag].present?

    # Поиск
    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      @uploads = @uploads
        .left_joins(:tags, :albums)
        .where(
          "LOWER(uploads.title) LIKE :q " \
          "OR LOWER(uploads.description) LIKE :q " \
          "OR LOWER(tags.name) LIKE :q " \
          "OR LOWER(albums.name) LIKE :q",
          q: q
        )
        .distinct
    end

    # Сортировка
    case params[:sort]
      when "oldest"
        @uploads = @uploads.reorder(created_at: :asc)
      when "title"
        # Сортировка в Ruby — понимает кириллицу
        @uploads = @uploads.to_a.sort_by do |u|
          [
            u.title.present? ? 0 : 1,
            u.title.to_s.downcase,
            -u.created_at.to_i
          ]
        end
      else
        @uploads = @uploads.reorder(created_at: :desc)
      end

      if @uploads.is_a?(Array)
        @uploads = Kaminari.paginate_array(@uploads).page(params[:page]).per(12)
      elsif @uploads.respond_to?(:page)
        @uploads = @uploads.page(params[:page]).per(12)
      end

      @albums = current_user.albums.recent
      @tags   = current_user.tags.order(:name)
  end
end