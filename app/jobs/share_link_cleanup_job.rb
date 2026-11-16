class ShareLinkCleanupJob < ApplicationJob
  queue_as :default

  def perform
    ShareLink.expired.where("expires_at < ?", 30.days.ago).delete_all
  end
end