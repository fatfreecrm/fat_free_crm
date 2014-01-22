# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/contacts/create" do
  include ContactsHelper

  before do
    login_and_assign
  end

  describe "create success" do
    before do
      assign(:contact, @contact = FactoryGirl.create(:contact))
      assign(:contacts, [ @contact ].paginate)
    end

    it "should hide [Create Contact] form and insert contact partial" do
      render

      rendered.should include("$('#contacts').prepend('<li class=\\'contact highlight\\' id=\\'contact_#{@contact.id}\\'")
      rendered.should include(%Q/$('#contact_#{@contact.id}').effect("highlight"/)
    end

    it "should refresh sidebar when called from contacts index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      render

      rendered.should include("#sidebar")
      rendered.should have_text("Recent Items")
    end

    it "should update pagination when called from contacts index" do
      controller.request.env["HTTP_REFERER"] = "http://localhost/contacts"
      render

      rendered.should include("#paginate")
    end

    it "should update recently viewed items when called from related asset" do
      render

      rendered.should include("#recently")
    end
  end

  describe "create failure" do
    it "create (failure): should re-render [create] template in :create_contact div" do
      assign(:contact, FactoryGirl.build(:contact, :first_name => nil)) # make it invalid
      @account = FactoryGirl.create(:account)
      assign(:users, [ FactoryGirl.create(:user) ])
      assign(:account, @account)
      assign(:accounts, [ @account ])

      render

      rendered.should include("$('#create_contact').html")
      rendered.should include(%Q/$('#create_contact').effect("shake"/)
    end
  end

end
