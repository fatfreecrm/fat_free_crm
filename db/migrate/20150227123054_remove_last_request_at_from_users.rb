# frozen_string_literal: true

class RemoveLastRequestAtFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :last_request_at
  end
end
