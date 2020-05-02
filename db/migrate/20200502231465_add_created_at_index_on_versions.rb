# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20140916011927)

class AddCreatedAtIndexOnVersions < ActiveRecord::Migration[4.2]
  def change
    add_index :fat_free_crm_versions, :created_at
  end
end
