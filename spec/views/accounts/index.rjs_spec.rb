# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index" do
  include AccountsHelper

  before do
    login_and_assign
  end

  it "should render [account] template with @accounts collection if there are accounts" do
    assign(:accounts, [ FactoryGirl.create(:account, :id => 42) ].paginate)

    render :template => 'accounts/index', :formats => [:js]
    
    rendered.should have_rjs("accounts") do |rjs|
      with_tag("li[id=account_#{42}]")
    end
    rendered.should have_rjs("paginate")
  end

  it "should render [empty] template if @accounts collection if there are no accounts" do
    assign(:accounts, [].paginate)

    render :template => 'accounts/index', :formats => [:js]
    
    rendered.should have_rjs("accounts") do |rjs|
      with_tag("div[id=empty]")
    end
    rendered.should have_rjs("paginate")
  end

end
