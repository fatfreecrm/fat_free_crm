# frozen_string_literal: true

class AddCreatedAtIndexOnVersions < ActiveRecord::Migration[4.2]
  def change
    add_index :versions, :created_at
  end
end
