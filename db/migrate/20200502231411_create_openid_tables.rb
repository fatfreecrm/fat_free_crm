# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030600)

class CreateOpenidTables < ActiveRecord::Migration[4.2]
  def self.up
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

  def self.down
    drop_table :fat_free_crm_open_id_authentication_associations
    drop_table :fat_free_crm_open_id_authentication_nonces
  end
end
