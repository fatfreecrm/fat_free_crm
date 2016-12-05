# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "admin/field_groups/update" do
  before do
    login_and_assign(admin: true)
    assign(:field_group, field_group)
  end

  let(:field_group) { FactoryGirl.build_stubbed(:field_group, label: 'test') }

  it "renders javascript" do
    render
    expect(view).to render_template("admin/field_groups/update")
    expect(rendered).to have_text("crm.flip_form('#{dom_id(field_group, :edit)}');")
    expect(rendered).to have_text("crm.set_title('#{dom_id(field_group)}'")
  end

  it "renders javascript for invalid field group" do
    allow(field_group.errors).to receive(:empty?).and_return(false)
    render
    expect(rendered).to have_text("$('##{dom_id(field_group, :edit)}').effect('shake', { distance:5 }, 250);")
  end
end
