# frozen_string_literal: true

class AddLatitudeAndLongitudeToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :latitude, :decimal, precision: 10, scale: 6
    add_column :accounts, :longitude, :decimal, precision: 10, scale: 6
  end
end
