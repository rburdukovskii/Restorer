class Upload < ApplicationRecord
  belongs_to :user

  has_one_attached :original
  has_one_attached :processed

  validates :original, presence: true
  validate :original_format_and_size

  STATUSES = %w[pending processing completed failed].freeze

  scope :recent, -> { order(created_at: :desc).limit(10) }

  def completed?
    status == "completed"
  end

  def processing?
    status == "processing"
  end

  private

  def original_format_and_size
    return unless original.attached?

    allowed = %w[image/jpeg image/jpg image/png image/webp]
    unless original.content_type.in?(allowed)
      errors.add(:original, "должно быть JPG, PNG или WebP")
    end

    if original.byte_size > 20.megabytes
      errors.add(:original, "не должно превышать 20 МБ")
    end
  end
end