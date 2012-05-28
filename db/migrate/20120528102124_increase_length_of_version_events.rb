class IncreaseLengthOfVersionEvents < ActiveRecord::Migration
  def up
    change_column :versions, :event, :string, :limit => 512
  end

  def down
    change_column :versions, :event, :string, :limit => 255
  end
end
