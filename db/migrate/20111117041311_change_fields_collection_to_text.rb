class ChangeFieldsCollectionToText < ActiveRecord::Migration
  def self.up
    change_column :fields, :collection, :text
  end

  def self.down
    change_column :fields, :collection, :string
  end
end
