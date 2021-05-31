# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/options" do
  before do
    login
  end

  it "should render [options] template into :options div and show it" do
    params[:cancel] = nil

    assign(:asset, "all")
    assign(:user, "all_users")
    assign(:action, "all_actions")
    assign(:duration, "two_days")
    assign(:all_users, [build_stubbed(:user)])

    render

    expect(rendered).to include("$('#options').html")
    expect(rendered).to include("$(\\\'#asset\\\').html(\\\'campaign\\\')")
    expect(rendered).to include("crm.flip_form('options')")
    expect(rendered).to include("crm.set_title('title', 'Recent Activity Options')")
  end

  it "should load :options partial with JavaScript code for menus" do
    params[:cancel] = nil
    assign(:asset, "all")
    assign(:action, "all_actions")
    assign(:user, "all_users")
    assign(:duration, "two_days")
    assign(:all_users, [build_stubbed(:user)])

    render

    expect(view).to render_template(partial: "_options")
  end

  it "should hide options form on Cancel" do
    params[:cancel] = "true"
    render

    expect(rendered).not_to include("$('#options').html")
    expect(rendered).to include("crm.flip_form('options')")
    expect(rendered).to include("crm.set_title('title', 'Recent Activity')")
  end
end
