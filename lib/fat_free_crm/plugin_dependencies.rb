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

# Plugin dependencies
Dir.glob(File.join(File.dirname(__FILE__), '..', 'plugins', '**')).each do |plugin_dir|
  # Add 'plugin/lib' to $LOAD_PATH
  $:.unshift File.expand_path(File.join(plugin_dir, 'lib'))
  require File.basename(plugin_dir)      # require 'plugin'
  require File.join(plugin_dir, 'init')  # require 'plugin/init'
end
