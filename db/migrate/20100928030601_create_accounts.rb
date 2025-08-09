# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :accounts, force: true do |t|
      t.string :uuid, limit: 36
      t.references :user
      t.integer :assigned_to
      t.string :name, limit: 64, null: false, default: ""
      t.string :access, limit: 8, default: "Public" # %w(Private Public Shared)
      t.string :website, limit: 64
      t.string :tall_free_phone, limit: 32
      t.string :phone, limit: 32
      t.string :fax, limit: 32
      t.string :billing_address
      t.string :shipping_address
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :accounts, %i[user_id name deleted_at], unique: true
    add_index :accounts, :assigned_to
  end

  def self.down
    drop_table :accounts
  end
end
