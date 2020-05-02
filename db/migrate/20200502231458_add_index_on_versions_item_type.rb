# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120413034923)

class AddIndexOnVersionsItemType < ActiveRecord::Migration[4.2]
  def change
    add_index :fat_free_crm_versions, :whodunnit
  end
end
