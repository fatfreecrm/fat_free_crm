# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/contacts/index" do
  include ContactsHelper

  before do
    login_and_assign
  end

  it "should render [contact] template with @contacts collection if there are contacts" do
    assign(:contacts, [ FactoryGirl.create(:contact, :id => 42) ].paginate)

    render :template => 'contacts/index', :formats => [:js]
    
    rendered.should have_rjs("contacts") do |rjs|
      with_tag("li[id=contact_#{42}]")
    end
    rendered.should have_rjs("paginate")
  end

  it "should render [empty] template if @contacts collection if there are no contacts" do
    assign(:contacts, [].paginate)

    render :template => 'contacts/index', :formats => [:js]
    
    rendered.should have_rjs("contacts") do |rjs|
      with_tag("div[id=empty]")
    end
    rendered.should have_rjs("paginate")
  end

end
