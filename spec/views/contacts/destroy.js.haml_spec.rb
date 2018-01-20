# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/contacts/destroy" do
  include ContactsHelper

  before do
    login
    assign(:contact, @contact = build_stubbed(:contact))
    assign(:contacts, [@contact].paginate)
  end

  it "should blind up destroyed contact partial" do
    render
    expect(rendered).to include("slideUp")
  end

  it "should update contacts sidebar when called from contacts index" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
    render

    expect(rendered).to include("#sidebar")
    expect(rendered).to have_text("Recent Items")
  end

  it "should update pagination when called from contacts index" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
    render

    expect(rendered).to include("#paginate")
  end

  it "should update recently viewed items when called from related asset" do
    controller.request.env["HTTP_REFERER"] = "http://localhost/accounts/123"
    render

    expect(rendered).to include("#recently")
  end
end
