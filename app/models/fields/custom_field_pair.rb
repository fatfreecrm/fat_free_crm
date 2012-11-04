# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class CustomFieldPair < CustomField

  has_one :pair, :class_name => CustomFieldPair, :foreign_key => 'pair_id', :dependent => :destroy # points to 'end'

  # Helper to create a pair. Used in fields_controller
  #------------------------------------------------------------------------------
  def self.create_pair(params)
    fields = params['field']
    as = params['field']['as']
    pair = params.delete('pair')
    base_params = fields.delete_if{|k,v| !%w(field_group_id label as).include?(k)}
    klass = ("custom_field_" + as.gsub('pair', '_pair')).classify.constantize
    field1 = klass.create( base_params.merge(pair['0']) )
    field2 = klass.create( base_params.merge(pair['1']).merge('pair_id' => field1.id, 'required' => field1.required, 'disabled' => field1.disabled) )
    [field1, field2]
  end
  
  # Helper to update a pair. Used in fields_controller
  #------------------------------------------------------------------------------
  def self.update_pair(params)
    fields = params['field']
    pair = params.delete('pair')
    base_params = fields.delete_if{|k,v| !%w(field_group_id label as).include?(k)}
    field1 = CustomFieldPair.find(params['id'])
    field1.update_attributes( base_params.merge(pair['0']) )
    field2 = field1.paired_with
    field2.update_attributes( base_params.merge(pair['1']).merge('required' => field1.required, 'disabled' => field1.disabled) )
    [field1, field2]
  end

  # Returns the field that this field is paired with
  #------------------------------------------------------------------------------
  def paired_with
    pair || CustomFieldPair.where(:pair_id => id).first
  end

end
