# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "home/index" do
  include HomeHelper

  before do
    login
  end

  it "should render [activity] template with @activities collection" do
    assign(:activities, [build_stubbed(:version, id: 42, event: "update", item: build_stubbed(:account), whodunnit: current_user.id.to_s)])

    render template: 'home/index', formats: [:js]

    expect(rendered).to include("$('#activities').html")
    expect(rendered).to include("li class=\\'version\\' id=\\'version_42\\'")
  end

  it "should render a message if there're no activities" do
    assign(:activities, [])

    render template: 'home/index', formats: [:js]

    expect(rendered).to include("No activity records found.")
  end
end
