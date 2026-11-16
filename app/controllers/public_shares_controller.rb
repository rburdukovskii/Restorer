class PublicSharesController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  layout "public"

  def show
    @share_link = ShareLink.find_by(token: params[:token])

    if @share_link.nil? || !@share_link.active?
      return render :not_found, status: :not_found
    end

    @shareable = @share_link.shareable

    case @shareable
    when Upload
      @share_link.register_view!
      render :upload
    when Album
      if params[:photo].present?
        # Просмотр конкретного фото из альбома
        @photo = @shareable.uploads.find_by(id: params[:photo])
        if @photo
          @shareable = @photo # Подменяем объект для вьюхи upload
          @share_link.register_view!
          render :upload
        else
          render :not_found, status: :not_found
        end
      else
        # Просмотр самого альбома
        @share_link.register_view!
        @uploads = @shareable.uploads.recent
        render :album
      end
    else
      render :not_found, status: :not_found
    end
  end

  def download
    @share_link = ShareLink.find_by(token: params[:token])
    return head :not_found unless @share_link&.active?

    shareable = @share_link.shareable

    if params[:photo].present? && shareable.is_a?(Album)
      upload = shareable.uploads.find_by(id: params[:photo])
      return head :not_found unless upload
      attachment = upload.processed.attached? ? upload.processed : upload.original
    elsif shareable.is_a?(Upload)
      attachment = shareable.processed.attached? ? shareable.processed : shareable.original
    else
      return head :not_found
    end

    return head :not_found unless attachment.attached?

    redirect_to rails_blob_url(attachment, disposition: "attachment"), allow_other_host: true
  end
end