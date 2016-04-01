class CreateWebkiosks < ActiveRecord::Migration
  def change
    create_table :webkiosks do |t|
      t.string :url
      t.references :account, index: true, foreign_key: true
      t.boolean :live
      t.string :platform
      t.text :notes

      t.timestamps null: false
    end
  end
end
