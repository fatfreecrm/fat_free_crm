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

  context "render" do
    let(:field) { FactoryBot.create(:field, as: as) }

    context "check_boxes" do
      let(:as) { "check_boxes" }
      it { expect(field.render([1, 2, 3])).to eql("1, 2<br />3") }
      it { expect(field.render([1, 2, 3])).to eql("1, 2<br />3") }
    end

    context "date" do
      let(:as) { "date" }
      it { expect(field.render(Time.parse('2011-04-19'))).to eql("Apr 19, 2011") }
    end

    context "datetime" do
      let(:as) { "datetime" }
      it { expect(field.render(Time.parse('2011-04-19 14:47 +0000'))).to eql("19 Apr 2011 at  2:47PM") }
    end
  end

end
