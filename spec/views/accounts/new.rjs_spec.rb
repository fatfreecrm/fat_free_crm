# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/new" do
  include AccountsHelper

  before do
    login_and_assign
    assign(:account, Account.new(:user => current_user))
    assign(:users, [ current_user ])
  end

  it "should toggle empty message div if it exists" do
    render

    rendered.should include('crm.flick("empty", "toggle")')
  end

  describe "new account" do
    it "should render [new] template into :create_account div" do
      params[:cancel] = nil
      render

      rendered.should have_rjs("create_account") do |rjs|
        with_tag("form[class=new_account]")
      end
      rendered.should include('crm.flip_form("create_account");')
    end
  end

  describe "cancel new account" do
    it "should hide [create account] form()" do
      params[:cancel] = "true"
      render

      rendered.should_not have_rjs("create_account")
      rendered.should include('crm.flip_form("create_account");')
    end
  end

end
