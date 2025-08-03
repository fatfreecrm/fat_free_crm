# frozen_string_literal: true

class CreateWebhookTargets < ActiveRecord::Migration[6.1]
  def change
    create_table :webhook_targets do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.boolean :enabled, default: false, null: false
      t.datetime :last_success_at

      t.timestamps
    end
  end
end
