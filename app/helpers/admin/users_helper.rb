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

module Admin::UsersHelper

  def link_to_suspend(user)
    link_to(t(:suspend) + "!", suspend_admin_user_path(user), :method => :put, :remote => true)
  end

  #----------------------------------------------------------------------------
  def link_to_reactivate(user)
    name = user.awaits_approval? ? t(:approve) + "!" : t(:reactivate) + "!"
    link_to(name, reactivate_admin_user_path(user), :method => :put, :remote => true)
  end

  #----------------------------------------------------------------------------
  def link_to_confirm(user)
    link_to(t(:delete) + "?", confirm_admin_user_path(user), :method => :get, :remote => true)
  end

  #----------------------------------------------------------------------------
  def link_to_delete(user)
    link_to_remote(t(:yes_button),
      :method => :delete,
      :url => admin_user_path(user),
      :before => visual_effect(:highlight, dom_id(user), :startcolor => "#ffe4e1")
    )
  end

  # User summary info for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def user_summary(user)
    summary = []
    title_and_company = user.title.blank? ? '' : h(user.title)
    title_and_company << " #{t(:at)} #{user.company}" unless user.company.blank?
    summary << title_and_company unless title_and_company.blank?
    summary << t('pluralize.login', user.login_count) if user.last_request_at && user.login_count > 0
    summary << user.email
    summary << "#{t :phone_small}: #{user.phone}" unless user.phone.blank?
    summary << "#{t :mobile_small}: #{user.mobile}" unless user.mobile.blank?
    summary << if !user.suspended?
      t(:user_since, l(user.created_at.to_date, :format => :mmddyy))
    elsif user.awaits_approval?
      t(:user_signed_up_on, l(user.created_at, :format => :mmddhhss))
    else
      t(:user_suspended_on, l(user.created_at.to_date, :format => :mmddyy))
    end
    summary << if user.awaits_approval?
      t(:user_signed_up)
    elsif user.suspended?
      t(:user_suspended)
    elsif user.admin?
      t(:user_admin)
    else
      t(:user_active)
    end
    summary.join(', ')
  end
end

