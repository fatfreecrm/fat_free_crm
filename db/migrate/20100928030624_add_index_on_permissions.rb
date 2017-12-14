class AddIndexOnPermissions < ActiveRecord::Migration
  def self.up
    add_index :permissions, %i[asset_id asset_type]
  end

  def self.down
    remove_index :permissions, %i[asset_id asset_type]
  end
end
