# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030624)

class AddIndexOnPermissions < ActiveRecord::Migration[4.2]
  def self.up
    add_index :fat_free_crm_permissions, %i[asset_id asset_type]
  end

  def self.down
    remove_index :fat_free_crm_permissions, %i[asset_id asset_type]
  end
end
