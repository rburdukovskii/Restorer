class AddFilterToUploads < ActiveRecord::Migration[8.0]
  def change
    add_column :uploads, :filter_name, :string
    add_column :uploads, :filter_params, :json, default: {}

    add_index :uploads, :filter_name
  end
end
