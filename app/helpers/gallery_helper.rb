module GalleryHelper
  def gallery_filter_params(**overrides)
    base = {
      favorites:     params[:favorites],
      without_album: params[:without_album],
      album:         params[:album],
      tag:           params[:tag],
      q:             params[:q],
      sort:          params[:sort]
    }.compact

    base.merge(overrides).compact
  end

  def gallery_filter_active?(*keys)
    keys.any? { |k| params[k].present? }
  end
end