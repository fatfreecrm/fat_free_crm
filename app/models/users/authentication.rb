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

class Authentication < Authlogic::Session::Base # NOTE: This is not ActiveRecord model.
  authenticate_with User
  after_save :check_if_suspended

  def to_key
    id ? id : nil
  end

  private

  # Override Authlogic's validate_by_password() to allow blank passwords. See
  # authlogic/lib/authlogic/session/password.rb for details.
  #----------------------------------------------------------------------------
  def validate_by_password
    self.invalid_password = false

    self.attempted_record = search_for_record(find_by_login_method, send(login_field))
    if attempted_record.blank?
      generalize_credentials_error_messages? ?
        add_general_credentials_error :
        errors.add(login_field, I18n.t('error_messages.login_not_found', :default => "is not valid"))
      return
    end

    if !attempted_record.send(verify_password_method, send("protected_#{password_field}"))
      self.invalid_password = true
      generalize_credentials_error_messages? ?
        add_general_credentials_error :
        errors.add(password_field, I18n.t('error_messages.password_invalid', :default => "is not valid"))
      return
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
    self.errors.add(:base, I18n.t(:msg_account_suspended)) if self.user.suspended?
  end
end
