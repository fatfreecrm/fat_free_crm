# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/accounts/index" do
  include AccountsHelper

  before do
    login_and_assign
  end

  it "should render [account] template with @accounts collection if there are accounts" do
    assign(:accounts, [ FactoryGirl.create(:account, :id => 42) ].paginate)

    render :template => 'accounts/index', :formats => [:js]

    rendered.should include("$('#accounts').html")
    rendered.should include("$('#paginate').html")
  end

  it "should render [empty] template if @accounts collection if there are no accounts" do
    assign(:accounts, [].paginate)

    render :template => 'accounts/index', :formats => [:js]

    rendered.should include("$('#accounts').html('<div id=\\'empty\\'")
    rendered.should include("$('#paginate').html")
  end

end
