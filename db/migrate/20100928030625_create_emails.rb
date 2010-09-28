class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails, :force => true do |t|
      t.string      :imap_message_id, :null => false  # IMAP internal message identifier.
      t.references  :user                             # User who created th email.
      t.references  :mediator, :polymorphic => true   # Identifies where the email is attached to.
      t.string      :sent_from, :null => false        # From:
      t.string      :sent_to, :null => false          # To:
      t.string      :cc                               # Cc:
      t.string      :bcc                              # Bcc:
      t.string      :subject                          # Subject:
      t.text        :body                             # Body:
      t.text        :header                           # Raw header as received from IMAP server.
      t.datetime    :sent_at                          # Time the message was sent.
      t.datetime    :received_at                      # Time the message was received.
      t.datetime    :deleted_at
      t.timestamps
    end

    add_index :emails, [ :mediator_id, :mediator_type ]
  end

  def self.down
    drop_table :emails
  end
end
