# frozen_string_literal: true

class AddTitleToFields < ActiveRecord::Migration[7.1]
  def change
    add_column :fields, :title, :string
  end
end
