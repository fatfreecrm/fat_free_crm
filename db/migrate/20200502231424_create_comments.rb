# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030613)

class CreateComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_comments do |t|
      t.references :user
      t.references :commentable, polymorphic: true
      t.boolean :private # TODO: add support for private comments.
      t.string :title, default: ""
      t.text :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :fat_free_crm_comments
  end
end
