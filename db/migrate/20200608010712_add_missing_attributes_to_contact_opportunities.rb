class AddMissingAttributesToContactOpportunities < ActiveRecord::Migration[6.0]
  def change
    add_column :fat_free_crm_contact_opportunities, :source_name, :string
    add_column :fat_free_crm_contact_opportunities, :source_relationship, :string
    add_column :fat_free_crm_contact_opportunities, :source_start_at, :datetime
    add_column :fat_free_crm_contact_opportunities, :source_end_at, :datetime
    add_column :fat_free_crm_contact_opportunities, :exposure_level, :string

  end
end