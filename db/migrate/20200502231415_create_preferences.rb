# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030604)

class CreatePreferences < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_preferences do |t|
      t.references :user
      t.string :name, limit: 64, null: false, default: ""
      t.text :value
      t.timestamps
    end
    add_index :fat_free_crm_preferences, %i[user_id name]
  end

  def self.down
    drop_table :fat_free_crm_preferences
  end
end
