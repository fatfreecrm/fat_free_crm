# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20150427131956)

class CreateIndexRelatedType < ActiveRecord::Migration[4.2]
  def up
    add_index :fat_free_crm_versions, %i[related_id related_type]
  end

  def down
    remove_index :fat_free_crm_versions, %i[related_id related_type]
  end
end
