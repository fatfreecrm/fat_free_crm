# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030627)

class ActsAsTaggableOnMigration < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_tags do |t|
      t.column :name, :string
    end

    create_table :fat_free_crm_taggings do |t|
      t.integer :tag_id
      t.integer :taggable_id
      t.integer :tagger_id
      t.string :tagger_type

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.string :taggable_type, limit: 50
      t.string :context, limit: 50

      t.column :created_at, :datetime
    end

    add_index :fat_free_crm_taggings, :tag_id
    add_index :fat_free_crm_taggings, %i[taggable_id taggable_type context], name: 'taggings_id_type_context'
  end

  def self.down
    drop_table :fat_free_crm_taggings
    drop_table :fat_free_crm_tags
  end
end
