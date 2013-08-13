# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "admin/field_groups/destroy" do

  before do
    login_and_assign(:admin => true)
    assign(:field_group, field_group)
  end

  let(:field_group) { FactoryGirl.build(:field_group) }

  it "renders destroy javascript" do
    field_group.stub(:destroyed?).and_return(true)
    render
    view.should render_template("admin/field_groups/destroy")
    rendered.should have_text("slideUp(250)")
  end

  it "renders 'not destroyed' javascript" do
    render
    view.should render_template("admin/field_groups/destroy")
    rendered.should have_text("Field Group could not be deleted")
    rendered.should have_text("crm.flash('warning');")
  end

end
