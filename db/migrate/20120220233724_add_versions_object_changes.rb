# frozen_string_literal: true

class AddVersionsObjectChanges < ActiveRecord::Migration[4.2]
  def up
    add_column :versions, :object_changes, :text
  end

  def down
    remove_column :versions, :object_changes
  end
end
