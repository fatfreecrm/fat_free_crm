# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120220233724)

class AddVersionsObjectChanges < ActiveRecord::Migration[4.2]
  def up
    add_column :fat_free_crm_versions, :object_changes, :text
  end

  def down
    remove_column :fat_free_crm_versions, :object_changes
  end
end
