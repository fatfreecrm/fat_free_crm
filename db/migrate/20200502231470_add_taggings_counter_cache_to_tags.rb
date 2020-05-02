# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20141230205454)

# This migration comes from acts_as_taggable_on_engine (originally 3)
class AddTaggingsCounterCacheToTags < ActiveRecord::Migration[4.2]
  def self.up
    add_column :fat_free_crm_tags, :taggings_count, :integer, default: 0

    #ActsAsTaggableOn::Tag.reset_column_information
    #ctsAsTaggableOn::Tag.find_each do |tag|
    #  ActsAsTaggableOn::Tag.reset_counters(tag.id, :fat_free_crm_taggings)
    #end
  end

  def self.down
    remove_column :fat_free_crm_tags, :taggings_count
  end
end
