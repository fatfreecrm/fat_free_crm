# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "accounts/show" do
  include AccountsHelper

  before do
    login
    @account = create(:account, id: 42,
                                contacts: [create(:contact)],
                                opportunities: [create(:opportunity)])
    assign(:account, @account)
    assign(:users, [current_user])
    assign(:comment, Comment.new)
    assign(:timeline, [create(:comment, commentable: @account)])

    # controller#controller_name and controller#action_name are not set in view specs
    allow(view).to receive(:template_for_current_view).and_return(nil)
  end

  it "should render account landing page" do
    render

    expect(view).to render_template(partial: "comments/_new")
    expect(view).to render_template(partial: "shared/_timeline")
    expect(view).to render_template(partial: "shared/_tasks")
    expect(view).to render_template(partial: "contacts/_contact")
    expect(view).to render_template(partial: "opportunities/_opportunity")

    expect(rendered).to have_tag("div[id=edit_account]")
  end
end
