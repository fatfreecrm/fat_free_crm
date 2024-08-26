# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::FieldsController do

  before(:each) do
    login_admin
    set_current_tab(:fields)
  end

  let(:field_group) { FactoryBot.create(:field_group) }

  describe "create" do
    it "should create a new custom field" do
      post :create, params: { field: { as: "email", label: "Email", field_group_id: field_group.id } }, xhr: true
      expect(assigns[:field].class).to eq(CustomField)
      expect(assigns[:field].valid?).to eq(true)
      expect(assigns[:field].label).to eq("Email")
      expect(response).to render_template("admin/fields/create")
    end

    it "should create a new custom field pair" do
      post :create, params: { field: { as: "date_pair", label: "Date Pair", field_group_id: field_group.id }, pair: {"0" => {hint: "Hint"}, "1" => {hint: "Hint"}} }, xhr: true
      expect(assigns[:field].class).to eq(CustomFieldDatePair)
      expect(assigns[:field].valid?).to eq(true)
      expect(assigns[:field].label).to eq("Date Pair")
      expect(response).to render_template("admin/fields/create")
    end
  end

end
