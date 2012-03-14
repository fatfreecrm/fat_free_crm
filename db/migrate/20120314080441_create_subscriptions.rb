class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references  :user                           # User who subscribes
      t.references  :entity, :polymorphic => true   # The entity that the user is subscribing to.

      # Event types bit field, using FlagShihTsu gem
      t.integer     :event_types, :null => false, :default => 0
      
      t.timestamps
    end
  end
end
