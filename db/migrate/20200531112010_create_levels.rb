class CreateLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :fat_free_crm_levels do |t|
      t.string :name
      t.references :facility

      t.timestamps
    end
  end
end
