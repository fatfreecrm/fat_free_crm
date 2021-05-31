# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: fields
#
#  id             :integer         not null, primary key
#  type           :string(255)
#  field_group_id :integer
#  position       :integer
#  name           :string(64)
#  label          :string(128)
#  hint           :string(255)
#  placeholder    :string(255)
#  as             :string(32)
#  collection     :text
#  disabled       :boolean
#  required       :boolean
#  maxlength      :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe CustomField do
  it "should add a column to the database" do
    expect(CustomField.connection).to receive(:add_column)
      .with("contacts", "cf_test_field", 'string', {})
    expect(Contact).to receive(:reset_column_information)
    expect(Contact).to receive(:serialize_custom_fields!)

    create(:custom_field,
           as: "string",
           name: "cf_test_field",
           label: "Test Field",
           field_group: create(:field_group, klass_name: "Contact"))
  end

  it "should generate a unique column name for a custom field" do
    field_group = build(:field_group, klass_name: "Contact")
    c = build(:custom_field, label: "Test Field", field_group: field_group)

    columns = []
    %w[cf_test_field cf_test_field_2 cf_test_field_3 cf_test_field_4].each do |field|
      expect(c.send(:generate_column_name)).to eq(field)
      allow(Contact).to receive(:column_names).and_return(columns << field)
    end
  end

  it "should evaluate the safety of database transitions" do
    c = build(:custom_field, as: "string")
    expect(c.send(:db_transition_safety, c.as, "email")).to eq(:null)
    expect(c.send(:db_transition_safety, c.as, "text")).to eq(:safe)
    expect(c.send(:db_transition_safety, c.as, "datetime")).to eq(:unsafe)

    c = build(:custom_field, as: "datetime")
    expect(c.send(:db_transition_safety, c.as, "date")).to eq(:safe)
    expect(c.send(:db_transition_safety, c.as, "url")).to eq(:unsafe)
  end

  it "should return a safe list of types for the 'as' select options" do
    { "email"   => %w[check_boxes text string email url tel select radio_buttons],
      "integer" => %w[integer float] }.each do |type, expected_arr|
      c = build(:custom_field, as: type)
      opts = c.available_as
      expect(opts.map(&:first)).to match_array(expected_arr)
    end
  end

  it "should change a column's type for safe transitions" do
    expect(CustomField.connection).to receive(:add_column)
      .with("contacts", "cf_test_field", 'string', {})
    expect(CustomField.connection).to receive(:change_column)
      .with("contacts", "cf_test_field", 'text', {})
    expect(Contact).to receive(:reset_column_information).twice
    expect(Contact).to receive(:serialize_custom_fields!).twice

    field_group = create(:field_group, klass_name: "Contact")
    c = create(:custom_field,
               label: "Test Field",
               name: nil,
               as: "email",
               field_group: field_group)
    c.as = "text"
    c.save
  end

  describe "in case a new custom field was added by a different instance" do
    it "should refresh column info and retry on assignment error" do
      expect(Contact).to receive(:reset_column_information)

      expect { Contact.new cf_unknown_field: 123 }.to raise_error(ActiveRecord::UnknownAttributeError)
    end

    it "should refresh column info and retry on attribute error" do
      expect(Contact).to receive(:reset_column_information)
      expect(Contact).to receive(:serialize_custom_fields!)

      contact = build(:contact)
      expect(contact.cf_another_new_field).to eq(nil)
    end
  end

  describe "validation" do
    it "should have errors if custom field is required" do
      event = CustomField.new(name: 'cf_event', required: true)
      foo = double(cf_event: nil)
      err = double(:errors)
      allow(err).to receive(:add)
      expect(foo).to receive(:errors).and_return(err)
      event.custom_validator(foo)
    end

    it "should have errors if custom field is longer than maxlength" do
      event = CustomField.new(name: 'cf_event', maxlength: 5)
      foo = double(cf_event: "This is too long")
      err = double(:errors)
      allow(err).to receive(:add)
      expect(foo).to receive(:errors).and_return(err)
      event.custom_validator(foo)
    end
  end
end
