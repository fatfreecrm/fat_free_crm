# frozen_string_literal: true

class ChangeFieldsCollectionToText < ActiveRecord::Migration[4.2]
  def self.up
    change_column :fields, :collection, :text
  end

  def self.down
    change_column :fields, :collection, :string
  end
end
