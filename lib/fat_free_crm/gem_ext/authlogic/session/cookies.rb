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

require 'action_controller'
require 'authlogic'

# Fix bug for default cookie name (use klass_name, instead of guessed_klass_name)
# Pull request pending: https://github.com/binarylogic/authlogic/pull/281
Authlogic::Session::Base.instance_eval do
  def cookie_key(value = nil)
    rw_config(:cookie_key, value, "#{klass_name.underscore}_credentials")
  end
end

