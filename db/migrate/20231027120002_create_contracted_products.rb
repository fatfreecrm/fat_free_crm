class CreateContractedProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :contracted_products do |t|
      t.references :contract, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
