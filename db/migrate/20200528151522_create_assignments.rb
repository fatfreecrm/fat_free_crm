class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :fat_free_crm_assignments do |t|
      t.references :account
      t.references :facility
     	t.references :contact
      t.date :start_on
      t.date :end_on

      t.timestamps
    end
  end
end