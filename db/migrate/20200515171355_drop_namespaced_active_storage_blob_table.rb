class DropNamespacedActiveStorageBlobTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :fat_free_crm_active_storage_blobs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
