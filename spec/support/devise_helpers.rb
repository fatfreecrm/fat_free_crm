# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php

module DeviseHelpers
  def login
    user = create :user
    perform_login(user)
  end

  def login_admin
    admin = FactoryBot.create(:user, admin: true)
    perform_login(admin)
  end

  def perform_login(user)
    user.confirm
    user.update_attribute(:suspended_at, nil)
    sign_in user
  end

  def current_user
    User.find_by_id(session['warden.user.user.key'][0][0])
  end
end
