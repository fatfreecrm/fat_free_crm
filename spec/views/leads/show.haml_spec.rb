# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show" do
  include LeadsHelper

  before do
    login_and_assign
    assign(:lead, @lead = FactoryGirl.build_stubbed(:lead, id: 42))
    assign(:users, [current_user])
    assign(:comment, Comment.new)
    assign(:timeline, [FactoryGirl.build_stubbed(:comment, commentable: @lead)])
  end

  it "should render lead landing page" do
    render
    expect(view).to render_template(partial: "comments/_new")
    expect(view).to render_template(partial: "shared/_timeline")
    expect(view).to render_template(partial: "shared/_tasks")

    expect(rendered).to have_tag("div[id=edit_lead]")
  end
end
