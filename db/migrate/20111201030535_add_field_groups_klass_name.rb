class AddFieldGroupsKlassName < ActiveRecord::Migration
  def up
    add_column :field_groups, :klass_name, :string, :limit => 32

    # Add a default field group for each model
    %w(Account Campaign Contact Lead Opportunity).each do |entity|
      klass = entity.classify.constantize
      field_group = FieldGroup.new
      field_group.label, field_group.klass_name = 'Custom Fields', klass.name
      field_group.save!
      Field.update_all({:field_group_id => field_group.id}, {:field_group_id => nil, :klass_name => klass.name})
    end
    FieldGroup.update_all('klass_name = (SELECT MAX(klass_name) FROM fields WHERE field_group_id = field_groups.id)', {:klass_name => nil})

    remove_column :fields, :klass_name
    Field.reset_column_information
  end

  def down
    add_column :fields, :klass_name, :string, :limit => 32
    connection.execute 'UPDATE fields SET klass_name = (SELECT MAX(klass_name) FROM field_groups WHERE field_groups.id = field_group_id)'
    remove_column :field_groups, :klass_name
  end
end
