# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "admin/field_groups/edit" do

  before do
    login_and_assign(:admin => true)
    assign(:field_group, field_group)
  end

  let(:field_group) { FactoryGirl.create(:field_group, :label => 'test') }

  it "renders javascript" do
    render
    view.should render_template("admin/field_groups/edit")
    rendered.should have_text("crm.show_form('#{dom_id(field_group, :edit)}')")
    rendered.should have_text("$('##{dom_id(field_group, :edit)}').html")
  end

end
