class AddDatesAndFacilityToOpportunities < ActiveRecord::Migration[6.0]
  def change
    add_column :fat_free_crm_opportunities, :start_on, :datetime
    add_column :fat_free_crm_opportunities, :end_on, :datetime
    add_reference :fat_free_crm_opportunities, :facility

  end
end