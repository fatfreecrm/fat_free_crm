class CreateAbsences < ActiveRecord::Migration[5.2]
  def change
    create_table :fat_free_crm_absences do |t|
      t.references :contact

      t.string :kind
      t.date :start_on
      t.date :end_on

      t.timestamp :deleted_at

      t.timestamps
    end
  end
end