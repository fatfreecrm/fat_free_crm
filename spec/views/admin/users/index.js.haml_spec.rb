# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/index" do
  before do
    login_and_assign
  end

  it "renders [admin/user] template with @users collection" do
    amy = FactoryGirl.create(:user)
    bob = FactoryGirl.create(:user)
    assign(:users, [ amy, bob ].paginate)

    render :template => 'admin/users/index', :formats => [:js]
    
    rendered.should include("id=\\'user_#{amy.id}\\'")
    rendered.should include("id=\\'user_#{bob.id}\\'")
    rendered.should include("$('#paginate')")
  end

end

