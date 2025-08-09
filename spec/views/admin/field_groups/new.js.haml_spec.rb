# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe "admin/field_groups/new" do
  before do
    login_admin
    assign(:field_group, field_group)
  end

  let(:field_group) { build_stubbed(:field_group, label: 'test') }

  it "renders javascript" do
    render
    expect(view).to render_template("admin/field_groups/new")
    expect(rendered).to have_text("crm.flick('empty', 'toggle')")
    expect(rendered).to have_text("crm.flip_form('#{field_group.klass_name.downcase}_create_field_group')")
    expect(rendered).to have_text("$('##{field_group.klass_name.downcase}_create_field_group').html")
  end
end
