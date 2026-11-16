class ShareLinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_share_link, only: [:destroy, :regenerate]

  def create
    shareable = find_shareable
    return head :not_found unless shareable
    return head :forbidden unless owner?(shareable)

    @share_link = ShareLink.find_or_create_active!(user: current_user, shareable: shareable)
    render_streams
  end

  def regenerate
    return head :forbidden unless @share_link.user == current_user
    @share_link.regenerate!
    render_streams
  end

  def destroy
    return head :forbidden unless @share_link.user == current_user
    @share_link.destroy
    redirect_back fallback_location: root_path, notice: "Ссылка удалена"
  end

  private

  def render_streams
    respond_to do |format|
      format.turbo_stream do
        streams = []
        
        # 1. Обновляем модалку (если она открыта в контейнере)
        streams << turbo_stream.replace(
          "share_link_modal_container",
          partial: "share_links/modal",
          locals: { share_link: @share_link }
        )

        # 2. Обновляем блок на странице фото (если мы на ней)
        if @share_link.shareable.is_a?(Upload)
          streams << turbo_stream.replace(
            "upload_share_link_#{@share_link.shareable_id}",
            partial: "uploads/share_link",
            locals: { upload: @share_link.shareable, share_link: @share_link }
          )
        end

        render turbo_stream: streams
      end

      format.json { render json: { url: public_share_url(@share_link.token) } }
    end
  end

  def set_share_link
    @share_link = ShareLink.find(params[:id])
  end

  def find_shareable
    type = params[:shareable_type]
    id   = params[:shareable_id]
    return nil unless %w[Upload Album].include?(type)
    type.constantize.find_by(id: id)
  end

  def owner?(shareable)
    shareable.respond_to?(:user) && shareable.user == current_user
  end
end