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

class Authentication < Authlogic::Session::Base # NOTE: This is not ActiveRecord model.
  authenticate_with User
  after_save :check_if_suspended

  verify_password_method :valid_ldap_credentials?
  find_by_login_method :update_or_create_from_ldap

  private

  # Override Authologic instance method in order to keep :login_count,
  # :last_login_at, and :last_login_ip intact if the user is suspended.
  # See vendor/plugin/authlogin/lib/authlogic/session/magic_columns.rb.
  #----------------------------------------------------------------------------
  def update_info
    super unless self.user.suspended?
  end

  #----------------------------------------------------------------------------
  def check_if_suspended
    self.errors.add_to_base(I18n.t(:msg_account_suspended)) if self.user.suspended?
  end

end
