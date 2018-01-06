# frozen_string_literal: true

class AddIndexOnPermissions < ActiveRecord::Migration[4.2]
  def self.up
    add_index :permissions, %i[asset_id asset_type]
  end

  def self.down
    remove_index :permissions, %i[asset_id asset_type]
  end
end
