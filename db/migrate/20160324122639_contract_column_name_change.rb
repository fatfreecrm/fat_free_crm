class ContractColumnNameChange < ActiveRecord::Migration
  def self.up
    rename_column :contracts, :type, :name
  end

  def self.down
  end
end
