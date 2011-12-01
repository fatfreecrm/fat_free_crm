class AddFieldGroupsKlassName < ActiveRecord::Migration
  def up
    add_column :field_groups, :klass_name, :string, :limit => 32

    # Add a default field group for each model
    Field::KLASSES.each do |klass|
      field_group = FieldGroup.create!(:label => 'Custom Fields', :klass_name => klass.name)
      Field.update_all({:field_group_id => field_group.id}, {:field_group_id => nil, :klass_name => klass.name})
    end
    FieldGroup.update_all('klass_name = (SELECT MAX(klass_name) FROM fields WHERE field_group_id = id)', {:klass_name => nil})

    remove_column :fields, :klass_name
  end

  def down
    add_column :fields, :klass_name, :string, :limit => 32
    connection.execute 'UPDATE fields SET klass_name = (SELECT MAX(klass_name) FROM field_groups WHERE id = field_group_id)'
    remove_column :field_groups, :klass_name
  end
end
