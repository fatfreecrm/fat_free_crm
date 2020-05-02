# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20101221123456)

class AddSingleAccessTokenToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_users, :single_access_token, :string
  end

  def self.down
    remove_column :fat_free_crm_users, :single_access_token
  end
end
