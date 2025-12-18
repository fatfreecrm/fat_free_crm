# frozen_string_literal: true

class CreateBundles < ActiveRecord::Migration[7.1]
  def change
    create_table :bundles do |t|
      t.integer :user_id
      t.string :name, limit: 128, null: false
      t.string :qr_code, limit: 255, null: false
      t.string :description
      t.string :location, limit: 128
      t.string :access, limit: 8, default: "Public"
      t.datetime :deleted_at, precision: nil
      t.text :subscribed_users
      t.timestamps
    end

    add_index :bundles, :user_id
    add_index :bundles, :qr_code, unique: true
    add_index :bundles, [:user_id, :name, :deleted_at], unique: true
    add_index :bundles, :deleted_at
  end
end
