# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20141230205453)

# This migration comes from acts_as_taggable_on_engine (originally 2)
class AddMissingUniqueIndices < ActiveRecord::Migration[4.2]
  def self.up
    add_index :fat_free_crm_tags, :name, unique: true

    remove_index :fat_free_crm_taggings, :tag_id
    remove_index :fat_free_crm_taggings, name: 'taggings_id_type_context'
    add_index :fat_free_crm_taggings,
              %i[tag_id taggable_id taggable_type context],
              unique: true, name: 'taggings_idx'
  end

  def self.down
    remove_index :fat_free_crm_tags, :name

    remove_index :fat_free_crm_taggings, name: 'taggings_idx'
    add_index :fat_free_crm_taggings, :tag_id
    add_index :fat_free_crm_taggings, %i[taggable_id taggable_type context]
  end
end
