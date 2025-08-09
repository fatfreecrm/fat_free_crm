# frozen_string_literal: true

class AddMinlengthToField < ActiveRecord::Migration[5.1]
  def change
    add_column :fields, :minlength, :integer, limit: 4, default: 0
  end
end
