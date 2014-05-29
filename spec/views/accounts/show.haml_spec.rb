# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/accounts/show" do
  include AccountsHelper

  before do
    login
    @account = FactoryGirl.create(:account, :id => 42,
      :contacts => [ FactoryGirl.create(:contact) ],
      :opportunities => [ FactoryGirl.create(:opportunity) ])
    assign(:account, @account)
    assign(:users, [ current_user ])
    assign(:comment, Comment.new)
    assign(:timeline, [ FactoryGirl.create(:comment, :commentable => @account) ])
  end

  it "should render account landing page" do
    render

    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "shared/_timeline")
    view.should render_template(:partial => "shared/_tasks")
    view.should render_template(:partial => "contacts/_contact")
    view.should render_template(:partial => "opportunities/_opportunity")

    rendered.should have_tag("div[id=edit_account]")
  end

end
