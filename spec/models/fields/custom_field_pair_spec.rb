# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe CustomFieldPair do
  class CustomFieldFooPair
  end

  it "should respond to pair" do
    expect(CustomFieldPair.new).to respond_to(:pair)
  end

  describe "create_pair" do
    before(:each) do
      @field = { 'as' => 'foopair', 'field_group_id' => 1, 'label' => 'Event' }
      @pair1 = { 'name' => 'pair1' }
      @pair2 = { 'name' => 'pair2' }
      @params = { 'field' => @field, 'pair' => { '0' => @pair1, '1' => @pair2 } }
    end

    it "should create the pair" do
      params1 = @field.merge(@pair1)
      foo1 = double(id: 3, required: true, disabled: 'false')
      expect(CustomFieldFooPair).to receive(:create).with(params1).and_return(foo1)
      params2 = @field.merge(@pair2).merge('pair_id' => 3, 'required' => true, 'disabled' => 'false')
      foo2 = double(id: 5)
      expect(CustomFieldFooPair).to receive(:create).with(params2).and_return(foo2)

      expect(CustomFieldPair.create_pair(@params)).to eq([foo1, foo2])
    end
  end

  describe "update_pair" do
    before(:each) do
      @field = { 'as' => 'foopair', 'field_group_id' => 1, 'label' => 'Event' }
      @pair1 = { 'name' => 'pair1' }
      @pair2 = { 'name' => 'pair2' }
      @params = { 'id' => '3', 'field' => @field, 'pair' => { '0' => @pair1, '1' => @pair2 } }
    end

    it "should update the pair" do
      foo1 = double(required: true, disabled: 'false')
      expect(foo1).to receive(:update).with(@field.merge(@pair1))
      foo2 = double
      expect(foo2).to receive(:update).with(@field.merge(@pair2).merge('required' => true, 'disabled' => 'false'))
      expect(foo1).to receive(:paired_with).and_return(foo2)
      expect(CustomFieldPair).to receive(:find).with('3').and_return(foo1)

      expect(CustomFieldPair.update_pair(@params)).to eq([foo1, foo2])
    end
  end

  describe "paired_with" do
    before(:each) do
      @field1 = CustomFieldDatePair.new(name: 'cf_event_from')
      @field2 = CustomFieldDatePair.new(name: 'cf_event_to')
    end

    it "should return the 2nd field" do
      expect(@field1).to receive(:pair).and_return(@field2)
      expect(@field1.paired_with).to eq(@field2)
    end

    it "should return the 1st field" do
      expect(@field2).to receive(:pair).and_return(nil)
      expect(@field2).to receive(:id).and_return(1)
      expect(CustomFieldPair).to receive(:where).with(pair_id: 1).and_return([@field1])
      expect(@field2.paired_with).to eq(@field1)
    end
  end
end
