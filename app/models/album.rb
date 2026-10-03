class Album < ApplicationRecord
  belongs_to :user
  has_many :photo_albums, dependent: :destroy
  has_many :uploads, through: :photo_albums
  has_one_attached :cover

  validates :name, presence: true, length: { maximum: 100 }

  scope :recent, -> { order(created_at: :desc) }

  def cover_image
    cover.attached? ? cover : uploads.first&.processed || uploads.first&.original
  end

  def photos_count
    uploads.count
  end
end
