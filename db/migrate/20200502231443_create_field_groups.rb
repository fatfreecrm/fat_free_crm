# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20111101090312)

class CreateFieldGroups < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_field_groups do |t|
      t.string :name,        limit: 64
      t.string :label,       limit: 128
      t.integer :position
      t.string :hint
      t.timestamps
    end
  end

  def self.down
    drop_table :fat_free_crm_field_groups
  end
end
