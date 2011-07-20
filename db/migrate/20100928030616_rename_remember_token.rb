class RenameRememberToken < ActiveRecord::Migration
  def self.up
    rename_column :users, :remember_token, :persistence_token
    remove_column :users, :openid_identifier
  end

  def self.down
    add_column :users, :openid_identifier, :string
    rename_column :users, :persistence_token, :remember_token
  end
end
