# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe CustomFieldPair do
  let(:field_group) { FactoryBot.create(:field_group) }

  it "should respond to pair" do
    expect(CustomFieldPair.new).to respond_to(:pair)
  end

  describe "create_pair" do
    let(:field_params) { { "as" => "date_pair", "field_group_id" => field_group.id, "label" => "New Field Pair" } }
    let(:pair_params) { { "0" => { "required" => "1" }, "1" => {} } }
    let(:params) { { "pair" => pair_params, "field" => field_params } }

    it "should create the pair" do
      field1, field2 = CustomFieldPair.create_pair(params)
      expect(field1.label).to eq("New Field Pair")
      expect(field1.as).to eq("date_pair")
      expect(field1.field_group_id).to eq(field_group.id)
      expect(field2.label).to eq("New Field Pair")
      expect(field2.as).to eq("date_pair")
      expect(field2.paired_with).to eq(field1)
    end
  end

  describe "update_pair" do
    let!(:field1) { CustomFieldPair.create!(name: 'cf_pair1', label: 'Date Pair', as: 'date_pair', hint: "", field_group: field_group, required: false, disabled: 'false') }
    let!(:field2) { CustomFieldPair.create!(name: 'cf_pair2', label: 'Date Pair', as: 'date_pair', hint: "", field_group: field_group, required: false, disabled: 'false', pair_id: field1.id) }

    let(:field_params) { { "label" => "Test Update" } }
    let(:pair_params) { { "0" => { "required" => "1", "id" => field1.id }, "1" => {} } }
    let(:params) { { "pair" => pair_params, "field" => field_params } }

    it "should update the pair" do
      expect(field1.label).to eq("Date Pair")
      expect(field2.label).to eq("Date Pair")
      expect(field1.required).to eq(false)
      expect(field2.required).to eq(false)

      CustomFieldPair.update_pair(params)
      field1.reload
      field2.reload

      expect(field1.label).to eq("Test Update")
      expect(field2.label).to eq("Test Update")
      expect(field1.required).to eq(true)
      expect(field2.required).to eq(true)
    end
  end

  describe "paired_with" do
    let!(:field1) { CustomFieldPair.create!(name: 'cf_event_from', label: 'From', as: 'date_pair', field_group: field_group) }
    let!(:field2) { CustomFieldPair.create!(name: 'cf_event_to', label: 'To', as: 'date_pair', field_group: field_group, pair_id: field1.id) }

    it "should return the 2nd field" do
      expect(field1.paired_with).to eq(field2)
    end

    it "should return the 1st field" do
      expect(field2.paired_with).to eq(field1)
    end
  end
end
