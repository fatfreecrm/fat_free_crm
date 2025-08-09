# frozen_string_literal: true

class AddHtml5ToFields < ActiveRecord::Migration[5.2]
  def change
    add_column :fields, :autofocus, :string
    add_column :fields, :autocomplete, :string
    add_column :fields, :list, :string
    add_column :fields, :multiple, :string
  end
end
