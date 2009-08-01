class AddSuspendedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :suspended_at, :datetime
    rename_column :accounts, :tall_free_phone, :toll_free_phone
  end

  def self.down
    rename_column :accounts, :toll_free_phone, :tall_free_phone
    remove_column :users, :suspended_at
  end
end
