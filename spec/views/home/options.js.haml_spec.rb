# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/options" do
  before do
    login_and_assign
  end

  it "should render [options] template into :options div and show it" do
    params[:cancel] = nil

    assign(:asset, "all")
    assign(:user, "all_users")
    assign(:action, "all_actions")
    assign(:duration, "two_days")
    assign(:all_users, [ FactoryGirl.create(:user) ])

    render

    rendered.should include("$('#options').html")
    rendered.should include("$(\\'#asset\\').html(\\'campaign\\')")
    rendered.should include("crm.flip_form('options')")
    rendered.should include("crm.set_title('title', 'Recent Activity Options')")
  end

  it "should load :options partial with JavaScript code for menus" do
    params[:cancel] = nil
    assign(:asset, "all")
    assign(:action, "all_actions")
    assign(:user, "all_users")
    assign(:duration, "two_days")
    assign(:all_users, [ FactoryGirl.create(:user) ])

    render

    view.should render_template(:partial => "_options")
  end

  it "should hide options form on Cancel" do
    params[:cancel] = "true"
    render

    rendered.should_not include("$('#options').html")
    rendered.should include("crm.flip_form('options')")
    rendered.should include("crm.set_title('title', 'Recent Activity')")
  end
end
