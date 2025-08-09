# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "admin/users/index" do
  before do
    login
  end

  it "renders [admin/user] template with @users collection" do
    amy = build_stubbed(:user)
    bob = build_stubbed(:user)
    assign(:users, [amy, bob].paginate)

    render template: 'admin/users/index', formats: [:js]

    expect(rendered).to include("id=\\'user_#{amy.id}\\'")
    expect(rendered).to include("id=\\'user_#{bob.id}\\'")
    expect(rendered).to include("$('#paginate')")
  end
end
