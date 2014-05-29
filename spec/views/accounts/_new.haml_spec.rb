# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/accounts/_new" do
  include AccountsHelper

  before do
    login
    assign(:account, Account.new)
    assign(:users, [ current_user ])
  end

  it "should render [create account] form" do
    render

    view.should render_template(:partial => "_top_section")
    view.should render_template(:partial => "_contact_info")
    view.should render_template(:partial => "_permissions")

    rendered.should have_tag("form[class=new_account]")
  end

  it "should render background info field if settings require so" do
    Setting.background_info = [ :account ]

    render
    rendered.should have_tag("textarea[id=account_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    Setting.background_info = []

    render
    rendered.should_not have_tag("textarea[id=account_background_info]")
  end

end
