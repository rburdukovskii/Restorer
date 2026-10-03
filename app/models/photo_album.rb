class PhotoAlbum < ApplicationRecord
  belongs_to :upload
  belongs_to :album
  
  validates :upload_id, uniqueness: { scope: :album_id }
end
