class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references  :user                           # User who subscribes
      t.references  :entity, :polymorphic => true   # The entity that the user is subscribing to.
      t.string      :event_type, :null => false

      t.timestamps
    end

    # Don't allow duplicate subscriptions
    add_index :subscriptions,
              [:user_id, :entity_id, :entity_type, :event_type],
              :unique => true,
              :name   => 'unique_subscriptions_index'

  end
end
