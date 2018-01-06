# frozen_string_literal: true

class AddVersionsRelated < ActiveRecord::Migration[4.2]
  def change
    add_column :versions, :related_id, :integer
    add_column :versions, :related_type, :string
  end
end
