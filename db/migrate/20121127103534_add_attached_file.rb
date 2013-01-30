class AddAttachedFile < ActiveRecord::Migration
  def up
    create_table :attached_files do |t|
      t.references :mandrill_email
      t.string :attached_file_file_name
      t.string :attached_file_content_type
      t.string :attached_file_file_size
      t.string :attached_file_updated_at
      t.timestamps
      t.string :deleted_at
    end
  end

  def down
    delete_table :attached_files
  end
end
