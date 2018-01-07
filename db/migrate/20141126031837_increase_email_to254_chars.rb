# frozen_string_literal: true

class IncreaseEmailTo254Chars < ActiveRecord::Migration[4.2]
  def up
    change_column :accounts, :email, :string, limit: 254
    change_column :contacts, :email, :string, limit: 254
    change_column :contacts, :alt_email, :string, limit: 254
    change_column :leads, :email, :string, limit: 254
    change_column :leads, :alt_email, :string, limit: 254
    change_column :users, :email, :string, limit: 254
    change_column :users, :alt_email, :string, limit: 254
  end

  def down
    change_column :accounts, :email, :string, limit: 64
    change_column :contacts, :email, :string, limit: 64
    change_column :contacts, :alt_email, :string, limit: 64
    change_column :leads, :email, :string, limit: 64
    change_column :leads, :alt_email, :string, limit: 64
    change_column :users, :email, :string, limit: 64
    change_column :users, :alt_email, :string, limit: 64
  end
end
