# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120121054235)

class CreateLists < ActiveRecord::Migration[4.2]
  def change
    create_table :fat_free_crm_lists do |t|
      t.string :name
      t.text :url

      t.timestamps
    end
  end
end
