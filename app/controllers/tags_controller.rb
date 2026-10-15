class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tag, only: [:destroy, :photos]

  def index
    @tags = current_user.tags
                       .left_joins(:photo_tags)
                       .group(:id)
                       .order("COUNT(photo_tags.id) DESC, tags.name ASC")

    # Поиск по тегам
    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      @tags = @tags.where("LOWER(tags.name) LIKE ?", q)
    end

    @tags_count = current_user.tags.count
  end

  def create
    tag = current_user.tags.find_or_create_by(name: params[:name].to_s.strip.downcase)
    redirect_back fallback_location: tags_path, notice: "Тег создан"
  end

  def destroy
    @tag.destroy
    redirect_back fallback_location: tags_path, notice: "Тег удалён"
  end

  def photos
    @uploads = @tag.uploads.recent
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  end
end