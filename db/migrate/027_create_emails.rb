class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails, :force => true do |t|
      t.string      :imap_message_id, :null => false          
      t.references  :user
      t.references  :mediator, :polymorphic => true
      t.string      :from, :null => false          
      t.string      :to, :null => false          
      t.string      :cc                             
      t.string      :bcc          
      t.string      :subject          
      t.text        :body
      t.datetime    :sent_at # Not obtained for now
      t.datetime    :received_at
      t.datetime    :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
