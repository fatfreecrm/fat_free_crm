# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20141230021159)

class AddTransactionIdColumnToVersions < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_versions, :transaction_id, :integer
    add_index :fat_free_crm_versions, [:transaction_id]
  end

  def self.down
    remove_index :fat_free_crm_versions, [:transaction_id]
    remove_column :fat_free_crm_versions, :transaction_id
  end
end
