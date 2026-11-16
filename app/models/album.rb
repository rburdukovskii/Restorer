class Album < ApplicationRecord
  belongs_to :user
  has_many :photo_albums, dependent: :destroy
  
  # Добавляем order, чтобы новые фото были первыми
  has_many :uploads, -> { order(created_at: :desc) }, through: :photo_albums
  
  has_many :share_links, as: :shareable, dependent: :destroy
  has_one_attached :cover

  validates :name, presence: true, length: { maximum: 100 }

  scope :recent, -> { order(created_at: :desc) }

  def cover_image
    return cover if cover.attached?

    first_photo_album = photo_albums.order(created_at: :asc).first
    return nil unless first_photo_album

    first_upload = first_photo_album.upload
    return nil unless first_upload

    # Возвращаем обработанное фото, если есть, иначе оригинал
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