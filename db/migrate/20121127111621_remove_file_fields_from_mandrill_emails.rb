class RemoveFileFieldsFromMandrillEmails < ActiveRecord::Migration
  def self.down
    add_column :mandrill_emails, :attached_file_file_name, :string
    add_column :mandrill_emails, :attached_file_content_type, :string
    add_column :mandrill_emails, :attached_file_file_size, :integer
    add_column :mandrill_emails, :attached_file_updated_at, :datetime
  end

  def self.up
    remove_column :mandrill_emails, :attached_file_file_name
    remove_column :mandrill_emails, :attached_file_content_type
    remove_column :mandrill_emails, :attached_file_file_size
    remove_column :mandrill_emails, :attached_file_updated_at
  end
end
