# Fat Free CRM
# Copyright (C) 2008-2009 by Michael Dvorkin
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
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class ActionController::Base
  
  # Extract helper names from files in app/helpers/*.rb -- no app/admin/helpers
  # or any other subdirectories are included.
  #----------------------------------------------------------------------------
  def self.application_helpers
    extract = /^#{Regexp.quote(helpers_dir)}\/?(.*)_helper.rb$/
    Dir["#{helpers_dir}/*_helper.rb"].map { |file| file.sub extract, '\1' }
  end 

end