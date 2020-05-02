# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030603)

class CreateSettings < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_settings do |t|
      t.string :name, limit: 32, null: false, default: ""
      t.text :value
      t.text :default_value
      t.timestamps
    end
    add_index :fat_free_crm_settings, :name
  end

  def self.down
    drop_table :fat_free_crm_settings
  end
end
