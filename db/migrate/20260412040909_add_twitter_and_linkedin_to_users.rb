# frozen_string_literal: true

class AddTwitterAndLinkedinToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.string :twitter, limit: 128
      t.string :linkedin, limit: 128
    end
  end
end
