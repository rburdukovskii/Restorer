class CreatePhotoAlbums < ActiveRecord::Migration[8.1]
  def change
    create_table :photo_albums do |t|
      t.references :upload, null: false, foreign_key: true
      t.references :album, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :photo_albums, [:upload_id, :album_id], unique: true
  end
end
