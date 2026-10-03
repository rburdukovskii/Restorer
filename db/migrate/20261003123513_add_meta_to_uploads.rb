class AddMetaToUploads < ActiveRecord::Migration[8.1]
  def change
    add_column :uploads, :title,       :string
    add_column :uploads, :description, :text
    add_column :uploads, :favorite,    :boolean, default: false, null: false

    add_index :uploads, :favorite
    add_index :uploads, :created_at
  end
end
