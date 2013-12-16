# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/accounts/create" do
  include AccountsHelper

  before do
    login_and_assign
  end

  # Note: [Create Account] is only called from Accounts index. Unlike other
  # core object Account partial is not embedded.
  describe "create success" do
    before do
      assign(:account, @account = FactoryGirl.create(:account))
      assign(:accounts, [ @account ].paginate)
      assign(:account_category_total, Hash.new(1))
      render
    end

    it "should hide [Create Account] form and insert account partial" do
      rendered.should include("$('#accounts').prepend('<li class=\\'account highlight\\' id=\\'account_#{@account.id}\\'")
      rendered.should include(%Q/$('#account_#{@account.id}').effect("highlight"/)
    end

    it "should update pagination" do
      rendered.should include("#paginate")
    end

    it "should refresh accounts sidebar" do
      rendered.should include("#sidebar")
      rendered.should have_text("Account Categories")
      rendered.should have_text("Recent Items")
    end
  end

  describe "create failure" do
    it "should re-render [create] template in :create_account div" do
      assign(:account, FactoryGirl.build(:account, :name => nil)) # make it invalid
      assign(:users, [ current_user ])
      render

      rendered.should include("#create_account")
      rendered.should include(%Q/$('#create_account').effect("shake"/)
    end
  end

end
