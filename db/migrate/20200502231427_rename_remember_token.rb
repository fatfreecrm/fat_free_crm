# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030616)

class RenameRememberToken < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :fat_free_crm_users, :remember_token, :persistence_token
    remove_column :fat_free_crm_users, :openid_identifier
  end

  def self.down
    add_column :fat_free_crm_users, :openid_identifier, :string
    rename_column :fat_free_crm_users, :persistence_token, :remember_token
  end
end
