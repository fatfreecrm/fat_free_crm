class AddFieldGroupsTagId < ActiveRecord::Migration
  def self.up
    add_column :field_groups, :tag_id, :integer
  end

  def self.down
    remove_column :field_groups, :tag_id
  end
end
