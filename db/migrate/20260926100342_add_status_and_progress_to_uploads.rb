class AddStatusAndProgressToUploads < ActiveRecord::Migration[8.1]
  def change
    add_column :uploads, :status, :string
    add_column :uploads, :progress, :integer
  end
end
