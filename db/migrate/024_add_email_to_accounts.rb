class AddEmailToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :email, :string, :limit => 64
  end

  def self.down
    remove_column :accounts, :email
  end
end
