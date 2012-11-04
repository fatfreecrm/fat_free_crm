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

module VersionsHelper

  # Parse the changes for each version
  #----------------------------------------------------------------------------
  def parse_version(attr_name, change)
    if attr_name =~ /^cf_/ and (field = CustomField.where(:name => attr_name).first).present?
      label = field.label
      first = field.render(change.first)
      second = field.render(change.second)
    else
      label = t(attr_name)
      first = change.first
      second = change.second
    end
    [label, first, second]
  end

  # Parse the version record for when a contact's account has changed.
  #----------------------------------------------------------------------------
  def parse_account_contact_version(version)
    label = t('contacts_account')
    old_id, new_id = version.changeset[:account_contact_id]
    old_name, new_name = version.changeset[:account_contact_name]
    first  = old_id.nil? ? nil : link_to(h(old_name), account_path(:id => old_id))
    second = new_id.nil? ? nil : link_to(h(new_name), account_path(:id => new_id))
    [label, first, second]
  end

end
