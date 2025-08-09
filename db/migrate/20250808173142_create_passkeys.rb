class CreatePasskeys < ActiveRecord::Migration[6.0]
  def change
    create_table :passkeys do |t|
      t.references :user, null: false, foreign_key: true
      t.string :label, null: false
      t.string :external_id, null: false
      t.string :public_key, null: false
      t.integer :sign_count, null: false, default: 0
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :passkeys, :external_id, unique: true
  end
end
