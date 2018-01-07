# frozen_string_literal: true

class AddFieldGroupsKlassName < ActiveRecord::Migration[4.2]
  def up
    add_column :field_groups, :klass_name, :string, limit: 32

    # Add a default field group for each model
    %w[Account Campaign Contact Lead Opportunity].each do |entity|
      klass = entity.classify.constantize
      field_group = FieldGroup.new
      field_group.label = 'Custom Fields'
      field_group.klass_name = klass.name
      field_group.save!
      Field.where(field_group_id: nil, klass_name: klass.name).update_all(field_group_id: field_group.id)
    end
    FieldGroup.where(klass_name: nil).update_all('klass_name = (SELECT MAX(klass_name) FROM fields WHERE field_group_id = field_groups.id)')

    remove_column :fields, :klass_name
    Field.reset_column_information
  end

  def down
    add_column :fields, :klass_name, :string, limit: 32
    connection.execute 'UPDATE fields SET klass_name = (SELECT MAX(klass_name) FROM field_groups WHERE field_groups.id = field_group_id)'
    remove_column :field_groups, :klass_name
  end
end
