# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/leads/_sidebar_show" do
  include LeadsHelper

  before do
    login
    assign(:users, [ current_user ])
    assign(:comment, Comment.new)
    assign(:lead, FactoryGirl.create(:lead,
                          :blog => 'http://www.blogger.com/home',
                          :linkedin => 'www.linkedin.com',
                          :twitter => 'twitter.com/account',
                          :facebook => ''))
  end

  it "should render working web presence links whether a protocol is provided or not" do
    render
    rendered.should have_tag("a[href=http://www.blogger.com/home]")
    rendered.should have_tag("a[href=http://www.linkedin.com]")
    rendered.should have_tag("a[href=http://twitter.com/account]")
    rendered.should_not have_tag("a[href=http://www.facebook/profile]")
  end
end
