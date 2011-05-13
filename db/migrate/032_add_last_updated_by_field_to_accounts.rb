class AddLastUpdatedByFieldToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :last_updated_by, :integer
  end

  def self.down
    remove_column :accounts, :last_updated_by
  end
end
