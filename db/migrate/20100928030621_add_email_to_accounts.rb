# frozen_string_literal: true

class AddEmailToAccounts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :accounts, :email, :string, limit: 64
  end

  def self.down
    remove_column :accounts, :email
  end
end
