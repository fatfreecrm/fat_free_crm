# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20180103223438)

class AddMinlengthToField < ActiveRecord::Migration[5.1]
  def change
    add_column :fat_free_crm_fields, :minlength, :integer, limit: 4, default: 0
  end
end
