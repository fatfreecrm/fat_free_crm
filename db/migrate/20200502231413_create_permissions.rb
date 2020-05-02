# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030602)

class CreatePermissions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_permissions do |t|
      t.references :user                      # User who is allowed to access the asset.
      t.references :asset, polymorphic: true  # Creates asset_id and asset_type.
      t.timestamps
    end

    add_index :fat_free_crm_permissions, :user_id
  end

  def self.down
    drop_table :fat_free_crm_permissions
  end
end
