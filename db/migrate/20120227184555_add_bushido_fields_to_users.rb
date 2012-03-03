class AddBushidoFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ido_id, :text
    add_column :users, :locale, :string
  end
end
