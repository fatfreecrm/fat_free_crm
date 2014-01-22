# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/index" do
  include HomeHelper

  before do
    login_and_assign
  end

  it "should render [activity] template with @activities collection" do
    assign(:activities, [ FactoryGirl.create(:version, :id => 42, :event => "update", :item => FactoryGirl.create(:account), :whodunnit => current_user.id.to_s) ])

    render :template => 'home/index', :formats => [:js]

    rendered.should include("$('#activities').html")
    rendered.should include("li class=\\'version\\' id=\\'version_42\\'")
  end

  it "should render a message if there're no activities" do
    assign(:activities, [])

    render :template => 'home/index', :formats => [:js]

    rendered.should include("No activity records found.")
  end

end
