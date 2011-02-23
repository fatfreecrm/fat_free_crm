class RemovePasswordFields < ActiveRecord::Migration
  def self.up
    remove_column :users, :password_hash
    remove_column :users, :password_salt
  end

  def self.down
    add_column :users, :password_salt, :string,                   :default => "",    :null => false
    add_column :users, :password_hash, :string,                   :default => "",    :null => false
  end
end
