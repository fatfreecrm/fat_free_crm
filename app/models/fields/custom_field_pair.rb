# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class CustomFieldPair < CustomField
  has_one :pair, class_name: 'CustomFieldPair', foreign_key: 'pair_id', dependent: :destroy # points to 'end'

  # Helper to create a pair. Used in fields_controller
  #------------------------------------------------------------------------------
  def self.create_pair(params)
    fields = params['field']
    as = params['field']['as']
    pair = params.delete('pair')
    base_params = fields.delete_if { |k, _v| !%w[field_group_id label as].include?(k) }
    klass = ("custom_field_" + as.gsub('pair', '_pair')).classify.constantize
    field1 = klass.create(base_params.merge(pair['0']))
    field2 = klass.create(base_params.merge(pair['1']).merge('pair_id' => field1.id, 'required' => field1.required, 'disabled' => field1.disabled))
    [field1, field2]
  end

  # Helper to update a pair. Used in fields_controller
  #------------------------------------------------------------------------------
  def self.update_pair(params)
    fields = params['field']
    pair = params.delete('pair')
    base_params = fields.delete_if { |k, _v| !%w[field_group_id label as].include?(k) }
    field1 = CustomFieldPair.find(params['id'])
    field1.update_attributes(base_params.merge(pair['0']))
    field2 = field1.paired_with
    field2.update_attributes(base_params.merge(pair['1']).merge('required' => field1.required, 'disabled' => field1.disabled))
    [field1, field2]
  end

  # Returns the field that this field is paired with
  #------------------------------------------------------------------------------
  def paired_with
    pair || CustomFieldPair.where(pair_id: id).first
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_custom_field_pair, self)
end
