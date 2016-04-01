class CreateKiosks < ActiveRecord::Migration
  def change
    create_table :kiosks do |t|
      t.string :name
      t.datetime :purchase_date
      t.string :contract_type
      t.integer :contract_length
      t.string :password
      t.string :cd_password
      t.text :notes

      t.timestamps null: false
    end
  end
end
