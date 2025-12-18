# frozen_string_literal: true

class CreateSamples < ActiveRecord::Migration[7.1]
  def change
    create_table :samples do |t|
      t.integer :user_id
      t.integer :bundle_id
      t.string :name, limit: 128, null: false
      t.string :brand, limit: 128
      t.string :location, limit: 128
      t.string :qr_code, limit: 255
      t.string :sku, limit: 64
      t.string :tiktok_affiliate_link, limit: 512
      t.boolean :has_fire_sale, default: false, null: false
      t.decimal :best_price, precision: 10, scale: 2
      t.decimal :original_price, precision: 10, scale: 2
      t.string :status, limit: 32, default: "available"
      t.string :access, limit: 8, default: "Public"
      t.text :description
      t.text :notes
      t.datetime :checked_out_at, precision: nil
      t.integer :checked_out_by
      t.datetime :deleted_at, precision: nil
      t.text :subscribed_users
      t.timestamps
    end

    add_index :samples, :user_id
    add_index :samples, :bundle_id
    add_index :samples, :qr_code, unique: true
    add_index :samples, :sku
    add_index :samples, :brand
    add_index :samples, :status
    add_index :samples, [:user_id, :name, :deleted_at], unique: true
    add_index :samples, :deleted_at
  end
end
