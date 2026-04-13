# frozen_string_literal: true

{
  'Account' => [
    {
      params: { label: 'General Information' },
      fields: [
        { field_type: '', name: '', label: '', required: '' },
        { field_type: '', name: '', label: '', required: '' },
        { field_type: '', name: '', label: '', required: '' }
      ]
    },
    {
      params: { label: 'Contact Information' },
      fields: []
    }
  ],
  'Campaign' => [
    {
      params: { label: 'General Information' },
      fields: [
        { field_type: '', name: '', label: '', required: '' },
        { field_type: '', name: '', label: '', required: '' },
        { field_type: '', name: '', label: '', required: '' }
      ]
    },
    {
      params: { label: 'Contact Information' },
      fields: []
    }
  ],
  'Contact' => [
    {
      params: { label: 'General Information' },
      fields: []
    },
    {
      params: { label: 'Extra Information' },
      fields: []
    },
    {
      params: { label: 'Web presence' },
      fields: []
    }
  ],
  'Lead' => [
    {
      params: { label: 'General Information' },
      fields: [
        { field_type: '', name: '', label: '', required: '' },
        { field_type: '', name: '', label: '', required: '' },
        { field_type: '', name: '', label: '', required: '' }
      ]
    },
    {
      params: { label: 'Contact Information' },
      fields: []
    }
  ],
  'Opportunity' => [
    {
      params: { label: 'General Information' },
      fields: [
        { field_type: '', name: '', label: '', required: '' },
        { field_type: '', name: '', label: '', required: '' },
        { field_type: '', name: '', label: '', required: '' }
      ]
    },
    {
      params: { label: 'Contact Information' },
      fields: []
    }
  ]
}.each_with_index do |(klass_name, groups), group_position|
  groups.each do |group|
    field_group = FieldGroup.create group[:params].merge(klass_name: klass_name, position: group_position)
    group[:fields].each_with_index do |params, field_position|
      Field.create params.merge(field_group: field_group, position: field_position)
    end
  end
end
