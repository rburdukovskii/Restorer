class ShareLink < ApplicationRecord
  belongs_to :user
  belongs_to :shareable, polymorphic: true

  TTL = 7.days

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :generate_token, on: :create
  before_validation :set_expires_at, on: :create

  scope :active, -> { where("expires_at > ?", Time.current).where(revoked_at: nil) }

  def active?
    revoked_at.nil? && expires_at > Time.current
  end

  def regenerate!
    update!(
      token: SecureRandom.urlsafe_base64(24),
      expires_at: TTL.from_now,
      views_count: 0
    )
  end

  def register_view!
    self.class.increment_counter(:views_count, id)
  end

  def public_url
    Rails.application.routes.url_helpers.public_share_url(token, host: default_host)
  end

  # Метод БЕЗ аргумента permission
  def self.find_or_create_active!(user:, shareable:)
    active
      .where(user: user, shareable: shareable)
      .order(created_at: :desc)
      .first || create!(user: user, shareable: shareable)
  end

  private

  def generate_token
    self.token ||= loop do
      candidate = SecureRandom.urlsafe_base64(24)
      break candidate unless self.class.exists?(token: candidate)
    end
  end

  def set_expires_at
    self.expires_at ||= TTL.from_now
  end

  def default_host
    Rails.application.config.action_mailer.default_url_options&.dig(:host) ||
      (Rails.env.production? ? "restorer.example.com" : "localhost:3000")
  end
end