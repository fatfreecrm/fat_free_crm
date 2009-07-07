class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars do |t|
      t.references  :user                         # Who uploaded the avatar.
      t.references  :entity, :polymorphic => true # User, and later on Lead, Contact, or Company
      t.integer     :image_file_size              # Uploaded image file size
      t.string      :image_file_name              # Uploaded image full file name
      t.string      :image_content_type           # MIME content type
      t.timestamps
    end
  end

  def self.down
    drop_table :avatars
  end
end
