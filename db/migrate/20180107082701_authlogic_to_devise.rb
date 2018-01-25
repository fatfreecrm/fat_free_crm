# frozen_string_literal: true

class AuthlogicToDevise < ActiveRecord::Migration[5.1]
  def self.up
    add_column :users, :unconfirmed_email, :string, limit: 254
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :remember_token, :string
    add_column :users, :remember_created_at, :datetime
    add_column :users, :authentication_token, :string
    add_column :users, :confirmation_token, :string, limit: 255
    add_column :users, :confirmed_at, :timestamp
    add_column :users, :confirmation_sent_at, :timestamp
    execute "UPDATE users SET confirmed_at = created_at, confirmation_sent_at = created_at"

    rename_column :users, :password_hash, :encrypted_password

    rename_column :users, :current_login_at, :current_sign_in_at
    rename_column :users, :last_login_at, :last_sign_in_at
    rename_column :users, :current_login_ip, :current_sign_in_ip
    rename_column :users, :last_login_ip, :last_sign_in_ip
    rename_column :users, :login_count, :sign_in_count

    remove_column :users, :persistence_token
    remove_column :users, :single_access_token
    remove_column :users, :perishable_token

    add_index :users, :reset_password_token, unique: true
    add_index :users, :remember_token,       unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :authentication_token, unique: true
  end

  def self.down
    add_column :users, :perishable_token, :string
    add_column :users, :single_access_token, :string
    add_column :users, :persistence_token, :string

    rename_column :users, :encrypted_password, :password_hash

    rename_column :users, :current_sign_in_at, :current_login_at
    rename_column :users, :last_sign_in_at, :last_login_at
    rename_column :users, :current_sign_in_ip, :current_login_ip
    rename_column :users, :last_sign_in_ip, :last_login_ip
    rename_column :users, :sign_in_count, :login_count

    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at

    remove_column :users, :unconfirmed_email
    remove_column :users, :authentication_token
    remove_column :users, :remember_created_at
    remove_column :users, :remember_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :reset_password_token
  end
end
