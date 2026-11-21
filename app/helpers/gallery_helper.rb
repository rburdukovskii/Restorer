module GalleryHelper
  def gallery_filter_active?(*filters)
    filters.any? do |filter|
      case filter
      when :favorites    then params[:favorites].present?
      when :without_album then params[:without_album].present?
      when :album        then params[:album].present?
      when :tag          then params[:tag].present?
      when :q            then params[:q].present?
      else false
      end
    end
  end
end