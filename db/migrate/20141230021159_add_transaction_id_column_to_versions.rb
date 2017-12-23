# frozen_string_literal: true

class AddTransactionIdColumnToVersions < ActiveRecord::Migration[4.2]
  def self.up
    add_column :versions, :transaction_id, :integer
    add_index :versions, [:transaction_id]
  end

  def self.down
    remove_index :versions, [:transaction_id]
    remove_column :versions, :transaction_id
  end
end
