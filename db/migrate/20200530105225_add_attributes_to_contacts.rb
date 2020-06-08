class AddAttributesToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :fat_free_crm_contacts, :gender, :string
    add_column :fat_free_crm_contacts, :preferred_name, :string
    add_column :fat_free_crm_contacts, :preferred_language, :string
    add_column :fat_free_crm_contacts, :outreach_priority, :integer
    add_column :fat_free_crm_contacts, :category, :string
    add_column :fat_free_crm_contacts, :used_interpreter, :string
  end
end