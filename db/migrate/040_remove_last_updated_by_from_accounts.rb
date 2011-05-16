class RemoveLastUpdatedByFromAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :last_updated_by 
  end

  def self.down
    add_column :accounts, :last_updated_by, :integer
  end
end
