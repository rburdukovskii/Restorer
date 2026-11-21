class ShareLinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_share_link, only: [:destroy, :regenerate]

  def create
    shareable = find_shareable
    return head :not_found unless shareable
    return head :forbidden unless owner?(shareable)

    @share_link = ShareLink.find_or_create_active!(user: current_user, shareable: shareable)
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "share_link_input_#{@share_link.shareable_id}",
          partial: "share_links/input",
          locals: { share_link: @share_link }
        )
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def regenerate
    return head :forbidden unless @share_link.user == current_user
    @share_link.regenerate!
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "share_link_input_#{@share_link.shareable_id}",
          partial: "share_links/input",
          locals: { share_link: @share_link }
        )
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def destroy
    return head :forbidden unless @share_link.user == current_user
    @share_link.destroy
    redirect_back fallback_location: root_path, notice: "Ссылка удалена"
  end

  private

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