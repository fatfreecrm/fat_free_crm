# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/comments/new" do
  include CommentsHelper

  before do
    assign(:comment, stub_model(Comment,
      :new_record? => true
    ))
    assign(:commentable, "contact")
    params["contact_id"] = "123"
  end

  it "should render new form" do
    render

    rendered.should include("hide()")
    rendered.should include("show()")
  end
end

