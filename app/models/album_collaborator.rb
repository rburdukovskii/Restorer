class AlbumCollaborator < ApplicationRecord
  belongs_to :album
  belongs_to :user
  belongs_to :invited_by, class_name: "User"

  ROLES = %w[editor].freeze

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :album_id, message: "уже является соавтором" }

  validate :cannot_invite_owner
  validate :cannot_invite_self

  scope :editors, -> { where(role: "editor") }

  private

  def cannot_invite_owner
    return unless album && user && album.user_id == user_id
    errors.add(:user, "не может быть владельцем альбома")
  end

  def cannot_invite_self
    return unless album && user && invited_by && user_id == invited_by_id
    errors.add(:user, "не может пригласить сам себя")
  end
end