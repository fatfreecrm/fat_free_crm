# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'FatFreeCRM::Fields' do
  class Foo
    include FatFreeCRM::Fields
    include ActiveModel::Validations
    has_fields
  end

  class Bar
    include FatFreeCRM::Fields
    include ActiveModel::Validations
  end

  it do
    expect(Foo.new).to respond_to(:field_groups)
  end

  it do
    expect(Foo).to respond_to(:serialize_custom_fields!)
  end

  it do
    expect(Foo).to respond_to(:fields)
  end

  it "calling has_fields should invoke serialize_custom_fields!" do
    expect(Bar).to receive(:serialize_custom_fields!)
    Bar.has_fields
  end

  describe "field_groups" do
    it "should call FieldGroup" do
      expect(ActiveRecord::Base.connection).to receive(:data_source_exists?).with('field_groups').and_return(true)
      dummy_scope = double
      expect(dummy_scope).to receive(:order).with(:position)
      expect(FieldGroup).to receive(:where).and_return(dummy_scope)
      Foo.new.field_groups
    end

    it "should not call FieldGroup if table doesn't exist (migrations not yet run)" do
      expect(ActiveRecord::Base.connection).to receive(:data_source_exists?).with('field_groups').and_return(false)
      expect(Foo.new.field_groups).to eq([])
    end
  end

  describe "fields" do
    before(:each) do
      @f1 = double(Field)
      @f2 = double(Field)
      @f3 = double(Field)
      @field_groups = [double(FieldGroup, fields: [@f1, @f2]), double(FieldGroup, fields: [@f3])]
    end

    it "should convert field_groups into a flattened list of fields" do
      expect(Foo).to receive(:field_groups).and_return(@field_groups)
      expect(Foo.fields).to eq([@f1, @f2, @f3])
    end
  end

  describe "serialize_custom_fields!" do
    before(:each) do
      @f1 = double(Field, as: 'check_boxes', name: 'field1')
      @f2 = double(Field, as: 'date', name: 'field2')
    end

    it "should serialize checkbox fields as Array" do
      allow(Foo).to receive(:serialized_attributes).and_return(field1: @f1, field2: @f2)
      expect(Foo).to receive(:fields).and_return([@f1, @f2])
      expect(Foo).to receive(:serialize).with(:field1, Array)
      Foo.serialize_custom_fields!
    end
  end

  it "should validate custom fields" do
    foo = Foo.new
    expect(foo).to receive(:custom_fields_validator)
    expect(foo).to be_valid
  end

  describe "custom_fields_validator" do
    before(:each) do
      @f1 = double(Field)
      @field_groups = [double(FieldGroup, fields: [@f1])]
    end

    it "should call custom_validator on each custom field" do
      foo = Foo.new
      expect(@f1).to receive(:custom_validator).with(foo)
      expect(foo).to receive(:field_groups).and_return(@field_groups)
      expect(foo).to be_valid
    end
  end
end
