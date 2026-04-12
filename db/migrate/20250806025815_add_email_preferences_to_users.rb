# frozen_string_literal: true

class AddEmailPreferencesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscribe_to_comment_replies, :boolean, default: true, null: false
    add_column :users, :receive_assigned_notifications, :boolean, default: true, null: false

    # Update existing records
    User.update_all(subscribe_to_comment_replies: true, receive_assigned_notifications: true)
  end
end
