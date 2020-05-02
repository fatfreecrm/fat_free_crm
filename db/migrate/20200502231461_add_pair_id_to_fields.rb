# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120801032706)

class AddPairIdToFields < ActiveRecord::Migration[4.2]
  def change
    add_column :fat_free_crm_fields, :pair_id, :integer
  end
end
