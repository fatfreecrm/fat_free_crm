class CreateIndexCases < ActiveRecord::Migration[5.2]
  def change
    create_table :fat_free_crm_index_cases do |t|
      t.references :user
      t.integer :assigned_to

      t.string :access
      t.string :source
      t.string :background_info

      t.timestamps
    end
  end
end
