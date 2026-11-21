class CreateAlbumCollaborators < ActiveRecord::Migration[8.1]
  def change
    create_table :album_collaborators do |t|
      t.references :album, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "editor"
      t.references :invited_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :album_collaborators, [ :album_id, :user_id ], unique: true
    add_index :album_collaborators, :role
  end
end