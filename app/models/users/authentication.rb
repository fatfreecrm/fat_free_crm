# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Authentication < Authlogic::Session::Base # NOTE: This is not ActiveRecord model.
  authenticate_with User
  after_save :check_if_suspended
  single_access_allowed_request_types :any

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
        errors.add(login_field, I18n.t('error_messages.login_not_found', default: "is not valid"))
      return
    end

    unless attempted_record.send(verify_password_method, send("protected_#{password_field}"))
      self.invalid_password = true
      generalize_credentials_error_messages? ?
        add_general_credentials_error :
        errors.add(password_field, I18n.t('error_messages.password_invalid', default: "is not valid"))
      return
    end
  end

  # Override Authologic instance method in order to keep :login_count,
  # :last_login_at, and :last_login_ip intact if the user is suspended.
  # See vendor/plugin/authlogin/lib/authlogic/session/magic_columns.rb.
  #----------------------------------------------------------------------------
  def update_info
    super unless user.suspended?
  end

  #----------------------------------------------------------------------------
  def check_if_suspended
    errors.add(:base, I18n.t(:msg_account_suspended)) if user.suspended?
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_authentication, self)
end
