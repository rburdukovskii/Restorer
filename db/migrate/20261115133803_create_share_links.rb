class CreateShareLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :share_links do |t|
      t.string   :token, null: false
      t.string   :shareable_type, null: false
      t.bigint   :shareable_id, null: false
      t.bigint   :user_id, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.integer  :views_count, null: false, default: 0
      t.timestamps
    end

    add_index :share_links, :token, unique: true
    add_index :share_links, [:shareable_type, :shareable_id]
    add_index :share_links, [:user_id, :shareable_type, :shareable_id], name: "index_share_links_on_user_and_shareable"
    add_index :share_links, :expires_at

    add_foreign_key :share_links, :users
  end
end