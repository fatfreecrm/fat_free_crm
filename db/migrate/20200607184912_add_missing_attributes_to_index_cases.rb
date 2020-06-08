class AddMissingAttributesToIndexCases < ActiveRecord::Migration[6.0]
  def change
    add_column :fat_free_crm_index_cases, :window_start_date, :datetime
    add_column :fat_free_crm_index_cases, :window_end_date, :datetime
    add_column :fat_free_crm_index_cases, :opened_at, :datetime
    add_column :fat_free_crm_index_cases, :closed_at, :datetime
    add_column :fat_free_crm_index_cases, :projected_return_date, :date
    add_reference :fat_free_crm_index_cases, :contact
    add_column :fat_free_crm_index_cases, :subscribed_users, :text

  end
end