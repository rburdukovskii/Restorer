class Upload < ApplicationRecord
  belongs_to :user

  has_one_attached :original
  has_one_attached :processed

  has_many :photo_albums, dependent: :destroy
  has_many :albums, through: :photo_albums

  has_many :photo_tags, dependent: :destroy
  has_many :tags, through: :photo_tags

  validates :original, presence: true
  validate :original_format_and_size

  STATUSES = %w[pending processing completed failed].freeze

  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :favorites, -> { where(favorite: true) }
  scope :with_tag,  ->(name) { joins(:tags).where(tags: { name: name.downcase }) }
  scope :in_album,  ->(album_id) { joins(:photo_albums).where(photo_albums: { album_id: album_id }) }
  scope :without_album, -> { left_joins(:photo_albums).where(photo_albums: { id: nil }) }

  def completed?
    status == "completed"
  end

  def processing?
    status == "processing"
  end

  def display_title
    title.presence || "Фото от #{created_at.strftime('%d.%m.%Y')}"
  end

  def add_tags(names)
    names.each do |tag_name|
      tag = user.tags.find_or_create_by(name: tag_name.strip.downcase)
      tags << tag unless tags.include?(tag)
    end
  end

  def remove_tag(name)
    return if name.nil?
    tag_to_remove = user.tags.find_by(name: name.strip.downcase)
    tags.delete(tag_to_remove) if tag_to_remove
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