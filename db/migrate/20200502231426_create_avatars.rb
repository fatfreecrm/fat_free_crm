# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20100928030615)

class CreateAvatars < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fat_free_crm_avatars do |t|
      t.references :user                      # Who uploaded the avatar.
      t.references :entity, polymorphic: true # User, and later on Lead, Contact, or Company
      t.integer :image_file_size              # Uploaded image file size
      t.string :image_file_name               # Uploaded image full file name
      t.string :image_content_type            # MIME content type
      t.timestamps
    end
  end

  def self.down
    drop_table :fat_free_crm_avatars
  end
end
