# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
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

module AddressesHelper
  
  # Setups a new address for forms and views (complex nested forms)
  #----------------------------------------------------------------------------
  def get_address(asset, type)
    asset.send("build_#{type}".to_sym) if asset.send(type.to_sym).nil?

    asset.send(type.to_sym)
  end

  # Generates the js code for copy from one address to another (used in accounts)
  #------------------------------------------------------------------------------  
  def copy_address_function(from, to)
    if Setting.single_address_field == true
      link_to_function t(:same_as_billing), %/$("#{from}_attributes_full_address").value = $("#{to}_attributes_full_address").value/
    else
      text = ""
      ['street1', 'street2', 'city', 'state', 'zipcode', 'country'].each do |field|
        text += "$(\"#{from}_attributes_#{field}\").value = $(\"#{to}_attributes_#{field}\").value;"
      end
      link_to_function t(:same_as_billing), %/#{text}/
    end   
  end
  
  # Checks if an address is empty (single and splitted)
  #----------------------------------------------------------------------------  
  def is_address_empty(address)
    if Setting.single_address_field == true
      address.full_address.nil? || address.full_address.empty?
    else
      is_empty = true
      ['street1', 'street2', 'city', 'state', 'zipcode', 'country'].each do |field|
        is_empty = false unless address.send(field).nil? || address.send(field).empty?
      end
      is_empty
    end
  end
end
