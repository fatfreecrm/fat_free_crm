class CreateContracts < ActiveRecord::Migration[6.1]
  def change
    create_table :contracts do |t|
      t.date :start_date
      t.date :end_date
      t.string :status
      t.text :contract_original_text
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
