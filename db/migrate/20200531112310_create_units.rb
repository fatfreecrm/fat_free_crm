class CreateUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :fat_free_crm_units do |t|
      t.string :name
      t.string :kind
      t.references :unitable, polymorphic: true

      t.timestamps
    end
  end
end
