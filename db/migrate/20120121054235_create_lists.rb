# frozen_string_literal: true

class CreateLists < ActiveRecord::Migration[4.2]
  def change
    create_table :lists do |t|
      t.string :name
      t.text :url

      t.timestamps
    end
  end
end
