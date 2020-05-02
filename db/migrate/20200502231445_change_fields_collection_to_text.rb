# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20111117041311)

class ChangeFieldsCollectionToText < ActiveRecord::Migration[4.2]
  def self.up
    change_column :fat_free_crm_fields, :collection, :text
  end

  def self.down
    change_column :fat_free_crm_fields, :collection, :string
  end
end
