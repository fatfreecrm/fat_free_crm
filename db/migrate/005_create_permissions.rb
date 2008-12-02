class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions, :force => true do |t|
      t.references :user                          # User who is allowed to access the asset.
      t.references :asset, :polymorphic => true   # Creates asset_id and asset_type.
      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end
