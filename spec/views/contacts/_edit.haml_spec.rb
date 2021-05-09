# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/_edit" do
  include ContactsHelper

  before do
    login
    assign(:account, @account = create(:account))
    assign(:accounts, [@account])
  end

  it "should render [edit contact] form" do
    assign(:contact, @contact = create(:contact))
    assign(:users, [current_user])

    render
    expect(view).to render_template(partial: "contacts/_top_section")
    expect(view).to render_template(partial: "contacts/_extra")
    expect(view).to render_template(partial: "contacts/_web")
    expect(view).to render_template(partial: "_permissions")

    expect(rendered).to have_tag('form[class="simple_form edit_contact"]') do
      with_tag "input[type=hidden][id=contact_user_id][value='#{@contact.user_id}']"
    end
  end

  it "should pick default assignee (Myself)" do
    assign(:users, [current_user])
    assign(:contact, create(:contact, assignee: nil))

    render
    expect(rendered).to have_tag("select[id=contact_assigned_to]") do |options|
      expect(options.to_s).not_to include(%(selected="selected"))
    end
  end

  it "should show correct assignee" do
    @user = create(:user)
    assign(:users, [current_user, @user])
    assign(:contact, create(:contact, assignee: @user))

    render
    expect(rendered).to have_tag("select[id=contact_assigned_to]") do |_options|
      with_tag "option[selected=selected]"
      with_tag "option[value='#{@user.id}']"
    end
  end

  it "should render background info field if settings require so" do
    assign(:users, [current_user])
    assign(:contact, create(:contact))
    Setting.background_info = [:contact]

    render
    expect(rendered).to have_tag("textarea[id=contact_background_info]")
  end

  it "should not render background info field if settings do not require so" do
    assign(:users, [current_user])
    assign(:contact, create(:contact))
    Setting.background_info = []

    render
    expect(rendered).not_to have_tag("textarea[id=contact_background_info]")
  end
end
