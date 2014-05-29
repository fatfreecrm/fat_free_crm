# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "/comments/edit" do
  include CommentsHelper

  before do
    login
    assign(:comment, stub_model(Comment,
      :id => 321,
      :new_record? => false,
      :commentable => stub_model(Contact, :id => '123')
    ))
    #params["contact_id"] = "123"
    assign(:current_user, current_user)
  end

  it "should render edit form" do
    render

    rendered.should include("textarea")
    rendered.should include("123")
  end
end
