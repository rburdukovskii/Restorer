class Album < ApplicationRecord
  belongs_to :user
  has_many :photo_albums, dependent: :destroy
  has_many :uploads, through: :photo_albums
  has_one_attached :cover

  validates :name, presence: true, length: { maximum: 100 }

  scope :recent, -> { order(created_at: :desc) }

  def cover_image
    return cover if cover.attached?

    first_upload = uploads.first
    return nil unless first_upload

    if first_upload.processed.attached?
      first_upload.processed
    else
      first_upload.original
    end
  end

  def photos_count
    uploads.count
  end
end
