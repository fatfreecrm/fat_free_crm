# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030618)

class AddAdminToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_users, :admin, :boolean, null: false, default: false
  end

  def self.down
    remove_column :fat_free_crm_users, :admin
  end
end
