class AddDateTimeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :starts_at, :datetime
    add_column :events, :ends_at, :datetime
  end
end
