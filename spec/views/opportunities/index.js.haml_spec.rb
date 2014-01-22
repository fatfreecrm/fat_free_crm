# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/opportunities/index" do
  include OpportunitiesHelper

  before do
    login_and_assign
    assign(:stage, Setting.unroll(:opportunity_stage))
  end

  it "should render [opportunity] template with @opportunities collection if there are opportunities" do
    assign(:opportunities, [ FactoryGirl.create(:opportunity, :id => 42) ].paginate)

    render :template => 'opportunities/index', :formats => [:js]

    rendered.should include("$('#opportunities').html")
    rendered.should include("#paginate")
  end

  it "should render [empty] template if @opportunities collection if there are no opportunities" do
    assign(:opportunities, [].paginate)

    render :template => 'opportunities/index', :formats => [:js]

    rendered.should include("$('#opportunities').html('<div id=\\'empty\\'>")
    rendered.should include("#paginate")
  end

end
