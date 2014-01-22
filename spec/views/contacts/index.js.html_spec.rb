# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/contacts/index" do
  include ContactsHelper

  before do
    login_and_assign
  end

  it "should render [contact] template with @contacts collection if there are contacts" do
    assign(:contacts, [ FactoryGirl.create(:contact, :id => 42) ].paginate)

    render :template => 'contacts/index', :formats => [:js]

    rendered.should include("$('#contacts').html('<li class=\\'contact highlight\\' id=\\'contact_42\\'")
    rendered.should include("#paginate")
  end

  it "should render [empty] template if @contacts collection if there are no contacts" do
    assign(:contacts, [].paginate)

    render :template => 'contacts/index', :formats => [:js]

    rendered.should include("$('#contacts').html('<div id=\\'empty\\'>")
    rendered.should include("#paginate")
  end

end
