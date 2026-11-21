class Album < ApplicationRecord
  belongs_to :user
  has_many :photo_albums, dependent: :destroy
  has_many :uploads, -> { order(created_at: :desc) }, through: :photo_albums
  has_many :share_links, as: :shareable, dependent: :destroy
  has_many :album_collaborators, dependent: :destroy
  has_many :collaborators, through: :album_collaborators, source: :user

  has_one_attached :cover

  validates :name, presence: true, length: { maximum: 100 }

  scope :recent, -> { order(created_at: :desc) }

  def cover_image
    return cover if cover.attached?

    first_photo_album = photo_albums.order(created_at: :asc).first
    return nil unless first_photo_album

    first_upload = first_photo_album.upload
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

  def owner?(user)
    self.user_id == user.id
  end

  def editable_by?(user)
    owner?(user) || album_collaborators.exists?(user: user, role: "editor")
  end

  def collaborator_role(user)
    return "owner" if owner?(user)
    collaborator = album_collaborators.find_by(user: user)
    collaborator&.role
  end
end