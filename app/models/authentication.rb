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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

class Authentication < Authlogic::Session::Base # NOTE: This is not ActiveRecord model.
  authenticate_with User

  private

  # Override Authlogic's validate_by_password() to allow blank passwords. See
  # authlogic/session/pasword.rb for details.
  #----------------------------------------------------------------------------
  def validate_by_password
    if send("protected_#{password_field}").blank?
      self.invalid_password = false
      self.attempted_record = search_for_record(find_by_login_method, send(login_field))
    else
      super # Password is not blank, authenticate as usual.
    end
  end
end
