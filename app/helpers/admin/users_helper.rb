# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Admin::UsersHelper
  def link_to_suspend(user)
    link_to(t(:suspend) + "!", suspend_admin_user_path(user), method: :put, remote: true)
  end

  #----------------------------------------------------------------------------
  def link_to_reactivate(user)
    name = user.awaits_approval? ? t(:approve) + "!" : t(:reactivate) + "!"
    link_to(name, reactivate_admin_user_path(user), method: :put, remote: true)
  end

  #----------------------------------------------------------------------------
  def link_to_confirm(user)
    link_to(t(:delete) + "?", confirm_admin_user_path(user), method: :get, remote: true)
  end

  # User summary info for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def user_summary(user)
    summary = []
    title_and_company = user_summary_title_and_company(user)
    summary << title_and_company unless title_and_company.blank?
    summary << t('pluralize.login', user.sign_in_count) if user.last_sign_in_at && user.sign_in_count.positive?
    summary << user.email
    summary << "#{t :phone_small}: #{user.phone}" unless user.phone.blank?
    summary << "#{t :mobile_small}: #{user.mobile}" unless user.mobile.blank?
    summary << user_summary_created_at(user)
    summary << user_summary_status(user)
    summary.join(', ')
  end

  private

  # Formatted user title and company for user summary
  def user_summary_title_and_company(user)
    str = user.title.blank? ? '' : h(user.title)
    str += " #{t(:at)} #{user.company}" unless user.company.blank?
    str
  end

  # Formatted user join date for user summary
  def user_summary_created_at(user)
    if !user.suspended?
      t(:user_since, l(user.created_at.to_date, format: :mmddyy))
    elsif user.awaits_approval?
      t(:user_signed_up_on, l(user.created_at, format: :mmddhhss))
    else
      t(:user_suspended_on, l(user.created_at.to_date, format: :mmddyy))
    end
  end

  # Formatted user status for user summary
  def user_summary_status(user)
    if user.awaits_approval?
      t(:user_signed_up)
    elsif user.suspended?
      t(:user_suspended)
    elsif user.admin?
      t(:user_admin)
    else
      t(:user_active)
    end
  end
end
