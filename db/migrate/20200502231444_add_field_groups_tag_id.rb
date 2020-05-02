# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20111116091952)

class AddFieldGroupsTagId < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_field_groups, :tag_id, :integer
  end

  def self.down
    remove_column :fat_free_crm_field_groups, :tag_id
  end
end
