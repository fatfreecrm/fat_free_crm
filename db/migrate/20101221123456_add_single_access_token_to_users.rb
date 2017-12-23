# frozen_string_literal: true

class AddSingleAccessTokenToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :single_access_token, :string
  end

  def self.down
    remove_column :users, :single_access_token
  end
end
