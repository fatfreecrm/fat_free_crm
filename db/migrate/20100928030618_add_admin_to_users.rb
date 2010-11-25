class AddAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :admin, :boolean, :null => false, :default => false
    superuser = User.first
    superuser.update_attribute(:admin, true) if superuser
  end

  def self.down
    remove_column :users, :admin
  end
end
