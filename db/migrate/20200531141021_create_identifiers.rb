class CreateIdentifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :fat_free_crm_identifiers do |t|
      t.references :identifiable, index: { name: 'identifiable_identifiers' }, polymorphic: true
      t.string :item
      t.string :kind
      t.string :key

      t.date :start_on
      t.date :end_on

      t.timestamps
    end
  end
end
