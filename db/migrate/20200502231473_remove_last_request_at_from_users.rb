# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20150227123054)

class RemoveLastRequestAtFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :fat_free_crm_users, :last_request_at
  end
end
