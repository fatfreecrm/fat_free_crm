class CreateInvestigations < ActiveRecord::Migration[6.0]
  def change
    create_table :fat_free_crm_investigations do |t|
      t.references :index_case
      t.string :status
      t.datetime :conducted_at
      t.text :subscribed_users
      t.references :user
      t.references :assigned_to

      t.timestamps
    end
  end
end
