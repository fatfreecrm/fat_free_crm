class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.integer "user_id"
      t.integer "assigned_to"
      t.string :name
      t.string :sku
      t.text :description
      t.string :image_url
      t.string :url
      t.string :gtin
      t.string :brand
      t.datetime :deleted_at
      t.text "subscribed_users"

      t.timestamps
    end

    add_index :products, %i[user_id name deleted_at], unique: true
    add_index :products, :assigned_to
  end
end
