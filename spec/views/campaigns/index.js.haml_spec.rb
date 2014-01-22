# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/campaigns/index" do
  include CampaignsHelper

  before do
    login_and_assign
  end

  it "should render [campaign] template with @campaigns collection if there are campaigns" do
    assign(:campaigns, [ FactoryGirl.create(:campaign, :id => 42) ].paginate)

    render :template => 'campaigns/index', :formats => [:js]
    
    rendered.should include("$('#campaigns').html('<li class=\\'campaign highlight\\' id=\\'campaign_42\\'")
    rendered.should include("#paginate")
  end

  it "should render [empty] template if @campaigns collection if there are no campaigns" do
    assign(:campaigns, [].paginate)

    render :template => 'campaigns/index', :formats => [:js]
    
    rendered.should include("$('#campaigns').html('<div id=\\'empty\\'>")
    rendered.should include("#paginate")
  end

end
