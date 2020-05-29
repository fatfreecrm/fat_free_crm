class CreateIndexCases < ActiveRecord::Migration[5.2]
  def change
    create_table :fat_free_crm_index_cases do |t|
      t.references :user
      t.references :assigned_to
      t.references :reporting_user

      t.string :access
      t.string :source
      t.string :background_info

      t.timestamps
    end
  end
end
