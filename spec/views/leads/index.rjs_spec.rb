# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/index" do
  include LeadsHelper

  before do
    login_and_assign
  end

  it "should render [lead] template with @leads collection if there are leads" do
    assign(:leads, [ FactoryGirl.create(:lead, :id => 42) ].paginate(:page => 1, :per_page => 20))

    render :template => 'leads/index', :formats => [:js]
    
    rendered.should have_rjs("leads") do |rjs|
      with_tag("li[id=lead_#{42}]")
    end
    rendered.should have_rjs("paginate")
  end

  it "should render [empty] template if @leads collection if there are no leads" do
    assign(:leads, [].paginate(:page => 1, :per_page => 20))

    render :template => 'leads/index', :formats => [:js]
    
    rendered.should have_rjs("leads") do |rjs|
      with_tag("div[id=empty]")
    end
    rendered.should have_rjs("paginate")
  end

end
