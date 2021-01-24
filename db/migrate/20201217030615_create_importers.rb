# frozen_string_literal: true

class CreateImporters < ActiveRecord::Migration[4.2]
  def self.up
    create_table :importers do |t|
      t.integer :attachment_file_size # Uploaded file size
      t.string :attachment_file_name, null: false # Uploaded full file name
      t.string :attachment_content_type # MIME content type
      t.string :entity_type, null: false # led, campaign
      t.string :entity_id # led, campaign
      t.string :status, null: false, default: :new # new, map , imported , error
      t.text :map
      t.text :messages
      t.timestamps
    end
  end

  def self.down
    drop_table :importers
  end
end
