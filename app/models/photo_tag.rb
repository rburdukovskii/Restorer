class PhotoTag < ApplicationRecord
  belongs_to :upload
  belongs_to :tag

  validates :upload_id, uniqueness: { scope: :tag_id }
end
