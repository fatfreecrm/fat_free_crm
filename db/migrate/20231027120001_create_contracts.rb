class CreateContracts < ActiveRecord::Migration[6.1]
  def change
    create_table :contracts do |t|
      t.integer "user_id"
      t.integer "assigned_to"
      t.date :start_date
      t.date :end_date
      t.string :status
      t.text :contract_original_text
      t.references :account, null: false, foreign_key: true
      t.text "subscribed_users"

      t.timestamps
    end
    add_index :contracts, %i[user_id name deleted_at], unique: true
    add_index :contracts, :assigned_to
  end
end
