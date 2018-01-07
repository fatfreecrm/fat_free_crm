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
#  minlength      :integer
#  maxlength      :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Field do
  it "should create a new instance given valid attributes" do
    Field.create!(
      name:      'skype_address',
      label:     'Skype address',
      as:        'string',
      minlength: 12,
      maxlength: 220,
      position:  10
    )
  end

  it "should return a list of field types" do
    expect(Field.field_types['string']).to eq('klass' => 'CustomField', 'type' => 'string')
  end

  it "should return a hash of input options" do
    expect(Field.new.input_options).to be_a(Hash)
  end

  it "should be able to display a empty multi_select value" do
    field = Field.new(
      label: "Availability",
      name:  "availability"
    )
    object = double('Object')

    #  as  |  value  |  expected
    [["check_boxes", [1, 2, 3], "1, 2<br />3"],
     %w[checkbox 0 no],
     ["checkbox", 1, "yes"],
     ["date", Time.parse('2011-04-19'), Time.parse('2011-04-19').strftime(I18n.t("date.formats.mmddyy"))]].each do |as, value, expected|
      field.as = as
      allow(object).to receive(field.name).and_return(value)
      expect(field.render_value(object)).to eq(expected)
    end
  end
end
