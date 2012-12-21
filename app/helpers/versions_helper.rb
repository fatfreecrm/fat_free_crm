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

    # Find account and link to it.
    if attr_name == 'account_id'
      if first.present? and (account = Account.find_by_id(first))
        first = link_to(h(account.name), account_path(account))
      end
      if second.present? and (account = Account.find_by_id(second))
        second  = link_to(h(account.name), account_path(account))
      end
    end

    [label, first, second]
  end

end
