class CreateDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :fat_free_crm_details do |t|
      t.string :name
      t.string :kind
      t.references :unit

      t.timestamps
    end
  end
end
