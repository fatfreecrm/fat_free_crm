# frozen_string_literal: true

class AddFieldGroupsTagId < ActiveRecord::Migration[4.2]
  def self.up
    add_column :field_groups, :tag_id, :integer
  end

  def self.down
    remove_column :field_groups, :tag_id
  end
end
