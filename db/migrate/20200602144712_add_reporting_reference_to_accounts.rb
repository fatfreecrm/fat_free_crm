class AddReportingReferenceToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_reference :fat_free_crm_accounts, :reports_to
  end
end