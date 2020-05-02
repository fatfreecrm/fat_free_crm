# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120309070209)

class AddVersionsRelated < ActiveRecord::Migration[4.2]
  def change
    add_column :fat_free_crm_versions, :related_id, :integer
    add_column :fat_free_crm_versions, :related_type, :string
  end
end
