class AddMinlengthToField < ActiveRecord::Migration
  def change
    add_column :fields, :minlength, :integer, limit: 4, default: 0
  end
end
