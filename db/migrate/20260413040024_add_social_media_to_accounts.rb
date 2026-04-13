# frozen_string_literal: true

class AddSocialMediaToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :blog, :string
    add_column :accounts, :linkedin, :string
    add_column :accounts, :facebook, :string
    add_column :accounts, :twitter, :string
    add_column :accounts, :bluesky, :string
    add_column :accounts, :instagram, :string
    add_column :accounts, :mastodon, :string
  end
end
