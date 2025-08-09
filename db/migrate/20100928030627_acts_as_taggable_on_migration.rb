# frozen_string_literal: true

class ActsAsTaggableOnMigration < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tags do |t|
      t.column :name, :string
    end

    create_table :taggings do |t|
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

    add_index :taggings, :tag_id
    add_index :taggings, %i[taggable_id taggable_type context]
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
