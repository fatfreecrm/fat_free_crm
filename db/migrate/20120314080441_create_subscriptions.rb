class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references  :user                           # User who subscribes
      t.references  :entity, :polymorphic => true   # The entity that the user is subscribing to.
      t.string      :event_type, :null => false
      
      t.timestamps
    end
  end
end
