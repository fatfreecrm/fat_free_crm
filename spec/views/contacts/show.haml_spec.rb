# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/show" do
  include ContactsHelper

  before do
    login_and_assign
    @contact = FactoryGirl.create(:contact, id: 42,
                                            opportunities: [FactoryGirl.create(:opportunity)])
    assign(:contact, @contact)
    assign(:users, [current_user])
    assign(:comment, Comment.new)
    assign(:timeline, [FactoryGirl.create(:comment, commentable: @contact)])
  end

  it "should render contact landing page" do
    render
    expect(view).to render_template(partial: "comments/_new")
    expect(view).to render_template(partial: "shared/_timeline")
    expect(view).to render_template(partial: "shared/_tasks")
    expect(view).to render_template(partial: "opportunities/_opportunity")

    expect(rendered).to have_tag("div[id=edit_contact]")
  end
end
