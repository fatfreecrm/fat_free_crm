class AddRecordColumnsToDocument < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :record_id, :string
    add_column :documents, :record_klass, :string
  end
end
