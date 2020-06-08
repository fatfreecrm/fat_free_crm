class CreateSections < ActiveRecord::Migration[6.0]
  def change
    create_table :fat_free_crm_sections do |t|
      t.string :name
      t.references :level

      t.timestamps
    end
  end
end