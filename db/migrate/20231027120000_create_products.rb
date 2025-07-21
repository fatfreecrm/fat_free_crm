class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.text :description
      t.string :image_url
      t.string :url
      t.string :gtin
      t.string :brand

      t.timestamps
    end
  end
end
