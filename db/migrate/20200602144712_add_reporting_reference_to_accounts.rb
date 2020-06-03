class AddReportingReferenceToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_reference :fat_free_crm_accounts, :reporting_accounts, foreign_key: true
  end
end