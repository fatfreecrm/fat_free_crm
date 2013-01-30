class AddMandrillEmails < ActiveRecord::Migration
  def change
    create_table :mandrill_emails, :force => true do |t|
      t.string :uuid, :limit => 36
      t.references :user
      t.string :mailing_list
      t.string :template
      t.string :from_address
      t.string :message_subject
      t.datetime :sent_at
      t.text :message_body
      t.integer :assigned_to
      t.string :name, :limit => 64, :null => false, :default => ""
      t.text :subscribed_users
      t.string :category, :limit => 32
      t.string :access, :limit => 8, :default => "Private" # %w(Private Public Shared)
      t.datetime    :deleted_at
      t.timestamps
    end
  end
end
