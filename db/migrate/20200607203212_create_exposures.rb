class CreateExposures < ActiveRecord::Migration[6.0]
  def change
    create_table :fat_free_crm_exposures do |t|
      t.references :index_case
      t.datetime :started_at
      t.datetime :ended_at
      t.string  :level
      t.references :contact
      t.references :facility
      t.boolean :used_mask
      t.references :user
      t.references :assigned_to
      t.text :subscribed_users

      t.timestamps
    end
  end
end