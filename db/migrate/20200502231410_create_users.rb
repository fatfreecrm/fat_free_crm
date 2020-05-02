# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030599)

class CreateUsers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_users do |t|
      t.string :uuid,             limit: 36
      t.string :username,         null: false, default: "", limit: 32
      t.string :email,            null: false, default: "", limit: 64
      t.string :first_name,       limit: 32
      t.string :last_name,        limit: 32
      t.string :title,            limit: 64
      t.string :company,          limit: 64
      t.string :alt_email,        limit: 64
      t.string :phone,            limit: 32
      t.string :mobile,           limit: 32
      t.string :aim,              limit: 32
      t.string :yahoo,            limit: 32
      t.string :google,           limit: 32
      t.string :skype,            limit: 32
      # >>> The following fields are required and maintained by [authlogic] plugin.
      t.string :password_hash,    null: false, default: ""
      t.string :password_salt,    null: false, default: ""
      t.string :remember_token,   null: false, default: ""
      t.string :perishable_token, null: false, default: ""
      t.string :openid_identifier
      t.datetime :last_request_at
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.string :last_login_ip
      t.string :current_login_ip
      t.integer :login_count, null: false, default: 0
      # >>> End of [authlogic] maintained fields.
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :fat_free_crm_users, %i[username deleted_at], unique: true
    add_index :fat_free_crm_users, :email
    add_index :fat_free_crm_users, :last_request_at
    add_index :fat_free_crm_users, :remember_token
    add_index :fat_free_crm_users, :perishable_token
  end

  def self.down
    drop_table :fat_free_crm_users
  end
end
