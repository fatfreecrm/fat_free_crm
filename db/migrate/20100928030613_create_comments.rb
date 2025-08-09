# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :comments, force: true do |t|
      t.references :user
      t.references :commentable, polymorphic: true
      t.boolean :private # TODO: add support for private comments.
      t.string :title, default: ""
      t.text :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
