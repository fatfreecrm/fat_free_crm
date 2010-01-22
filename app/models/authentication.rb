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

  private

  # Override Authlogic's validate_by_password() to allow blank passwords. See
  # authlogic/lib/authlogic/session/password.rb for details.
  #----------------------------------------------------------------------------
  def validate_by_password
    self.invalid_password = false

    self.attempted_record = search_for_record(find_by_login_method, send(login_field))
    if self.attempted_record.blank?
      errors.add(login_field, :is_not_valid)
    else
      # Run password verification first, but then adjust the validity if both
      # password hash and password field are blank.
      self.invalid_password = !self.attempted_record.send(verify_password_method, send("protected_#{password_field}"))
      if self.attempted_record.password_hash.blank? && send("protected_#{password_field}").blank?
        self.invalid_password = false
      end
      if self.invalid_password?
        errors.add(password_field, :is_not_valid)
      end
    end
  end

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
