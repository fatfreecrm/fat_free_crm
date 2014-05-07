class CreateAccountMediaProperties < ActiveRecord::Migration
  def change
    create_table :account_media_properties do |t|
      t.references :account
      t.string :media_type, :limit => 250
      t.text :description

      t.timestamps
    end
    add_index :account_media_properties, :account_id
  end
end
