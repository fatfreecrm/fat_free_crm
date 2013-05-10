# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/accounts/destroy" do
  include AccountsHelper

  before do
    login_and_assign
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ].paginate)
    assign(:account_category_total, Hash.new(1))
    render
  end

  it "should blind up destroyed account partial" do
    rendered.should include("slideUp")
  end

  it "should update accounts pagination" do
    rendered.should include("#paginate")
  end

  it "should update accounts sidebar" do
    rendered.should include("#sidebar")
    rendered.should have_text("Account Categories")
    rendered.should have_text("Recent Items")
  end

end
