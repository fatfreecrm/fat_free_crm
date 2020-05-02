# This migration comes from fat_free_crm (originally 20200501015245)
class AddRecordColumnsToDocument < ActiveRecord::Migration[6.0]
  def change
    add_column :fat_free_crm_documents, :record_id, :string
    add_column :fat_free_crm_documents, :record_klass, :string
  end
end
