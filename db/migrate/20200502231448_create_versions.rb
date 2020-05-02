# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120216031616)

class CreateVersions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_versions do |t|
      t.string :item_type, null: false
      t.integer :item_id, null: false
      t.string :event, null: false
      t.string :whodunnit
      t.text :object
      t.datetime :created_at
    end
    add_index :fat_free_crm_versions, %i[item_type item_id], name: 'big_index2'
  end

  def self.down
    remove_index :fat_free_crm_versions, %i[item_type item_id]
    drop_table :fat_free_crm_versions
  end
end
