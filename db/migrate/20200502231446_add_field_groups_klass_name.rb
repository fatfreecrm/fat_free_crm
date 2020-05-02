# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20111201030535)

class AddFieldGroupsKlassName < ActiveRecord::Migration[4.2]
  def up
    add_column :fat_free_crm_field_groups, :klass_name, :string, limit: 32

    # Add a default field group for each model
    %w[Account Campaign Contact Lead Opportunity].each do |entity|
      klass = "FatFreeCrm::#{entity.classify}".constantize
      field_group = FatFreeCrm::FieldGroup.new
      field_group.label = 'Custom Fields'
      field_group.klass_name = klass.name
      field_group.save!
      FatFreeCrm::Field.where(field_group_id: nil, klass_name: klass.name).update_all(field_group_id: field_group.id)
    end
    FatFreeCrm::FieldGroup.where(klass_name: nil).update_all('klass_name = (SELECT MAX(klass_name) FROM fat_free_crm_fields WHERE field_group_id = fat_free_crm_field_groups.id)')

    remove_column :fat_free_crm_fields, :klass_name
    FatFreeCrm::Field.reset_column_information
  end

  def down
    add_column :fat_free_crm_fields, :klass_name, :string, limit: 32
    connection.execute 'UPDATE fields SET klass_name = (SELECT MAX(klass_name) FROM fat_free_crm_field_groups WHERE fat_free_crm_field_groups.id = field_group_id)'
    remove_column :fat_free_crm_field_groups, :klass_name
  end
end
