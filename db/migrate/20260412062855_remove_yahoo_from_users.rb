# frozen_string_literal: true

class RemoveYahooFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :yahoo, :string
  end
end
