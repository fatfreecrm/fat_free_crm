# frozen_string_literal: true

class DropOpenidTables < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
  end

  # see 003_create_openid_tables.rb
  def self.down
    create_table :open_id_authentication_associations, force: true do |t|
      t.integer :issued
      t.integer :lifetime
      t.string :handle
      t.string :assoc_type
      t.binary :server_url
      t.binary :secret
    end

    create_table :open_id_authentication_nonces, force: true do |t|
      t.integer :timestamp, null: false
      t.string :server_url, null: true
      t.string :salt,       null: false
    end
  end
end
