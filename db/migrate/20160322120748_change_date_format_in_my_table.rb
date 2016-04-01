class ChangeDateFormatInMyTable < ActiveRecord::Migration
  def up
    change_column :kiosks, :purchase_date, :date
  end
  def down
    change_column :kiosks, :purchase_date, :datetime
  end
end
