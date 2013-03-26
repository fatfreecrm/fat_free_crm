# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/_edit" do
  include ContactsHelper

  before do
    login_and_assign
    assign(:account, @account = FactoryGirl.create(:account))
    assign(:accounts, [ @account ])
  end

  it "should render [edit contact] form" do
    assign(:contact, @contact = FactoryGirl.create(:contact))
    assign(:users, [ current_user ])

    render
    view.should render_template(:partial => "contacts/_top_section")
    view.should render_template(:partial => "contacts/_extra")
    view.should render_template(:partial => "contacts/_web")
    view.should render_template(:partial => "_permissions")

    rendered.should have_tag("form[class=edit_contact]") do
      with_tag "input[type=hidden][id=contact_user_id][value=#{@contact.user_id}]"
    end
  end

  it "should pick default assignee (Myself)" do
    assign(:users, [ current_user ])
    assign(:contact, FactoryGirl.create(:contact, :assignee => nil))

    render
    rendered.should have_tag("select[id=contact_assigned_to]") do |options|
      options.to_s.should_not include(%Q/selected="selected"/)
    end
  end

  it "should show correct assignee" do
    @user = FactoryGirl.create(:user)
    assign(:users, [ current_user, @user ])
    assign(:contact, FactoryGirl.create(:contact, :assignee => @user))

    render
    rendered.should have_tag("select[id=contact_assigned_to]") do |options|
      with_tag "option[selected=selected]"
      with_tag "option[value=#{@user.id}]"
    end
  end

  it "should render background info field if settings require so" do
    assign(:users, [ current_user ])
    assign(:contact, FactoryGirl.create(:contact))
    Setting.background_info = [ :contact ]

    render
    rendered.should have_tag("textarea[id=contact_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    assign(:users, [ current_user ])
    assign(:contact, FactoryGirl.create(:contact))
    Setting.background_info = []

    render
    rendered.should_not have_tag("textarea[id=contact_background_info]")
  end
end
