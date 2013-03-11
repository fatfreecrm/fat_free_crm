class MigrateAuthlogicDevise < ActiveRecord::Migration
  def up
    # rename_column :users, :crypted_password, :encrypted_password
    
   # execute "UPDATE users SET confirmed_at = created_at, confirmation_sent_at = created_at"
    
    rename_column :users, :login_count, :sign_in_count
    rename_column :users, :current_login_at, :current_sign_in_at
    rename_column :users, :last_login_at, :last_sign_in_at
    rename_column :users, :current_login_ip, :current_sign_in_ip
    rename_column :users, :last_login_ip, :last_sign_in_ip
    
    remove_column :users, :persistence_token
    remove_column :users, :perishable_token
    remove_column :users, :single_access_token
  end

  def down
  end
end
