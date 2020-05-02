# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030617)

class DropOpenidTables < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :fat_free_crm_open_id_authentication_associations
    drop_table :fat_free_crm_open_id_authentication_nonces
  end

  def self.down # see 003_create_openid_tables.rb
    create_table :fat_free_crm_open_id_authentication_associations do |t|
      t.integer :issued
      t.integer :lifetime
      t.string :handle
      t.string :assoc_type
      t.binary :server_url
      t.binary :secret
    end

    create_table :fat_free_crm_open_id_authentication_nonces do |t|
      t.integer :timestamp, null: false
      t.string :server_url, null: true
      t.string :salt,       null: false
    end
  end
end
