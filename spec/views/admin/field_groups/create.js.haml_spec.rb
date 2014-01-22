# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "admin/field_groups/create" do

  before do
    login_and_assign(:admin => true)
    assign(:field_group, field_group)
  end

  let(:field_group) { FactoryGirl.create(:field_group, :label => 'test') }

  it "renders javascript" do
    render
    view.should render_template("admin/field_groups/create")
    rendered.should have_text("$('##{field_group.klass_name.downcase}_create_field_group_arrow')")
    rendered.should have_text("$('##{dom_id(field_group)}').effect('highlight', { duration:1500 });")
  end

  it "renders javascript for invalid field group" do
    field_group.stub(:valid?).and_return(false)
    render
    view.should render_template("admin/field_groups/create")
    rendered.should have_text("effect(\"shake\", { duration:250, distance: 6 });")
  end

end
