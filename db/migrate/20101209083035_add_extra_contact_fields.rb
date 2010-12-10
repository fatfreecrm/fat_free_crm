class AddExtraContactFields < ActiveRecord::Migration
  def self.up
    change_table :contacts do |t|
      t.string :chinese_name
      t.string :preferred_name
      t.string :salutation
    end
  end

  def self.down
    change_table :contacts do |t|
      t.remove :chinese_name
      t.remove :preferred_name
      t.remove :salutation
    end
  end
end
