# frozen_string_literal: true

class RemoveAimFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :aim, :string, limit: 32
  end
end
