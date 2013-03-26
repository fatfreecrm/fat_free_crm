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
    CustomFieldPair.new.should respond_to(:pair)
  end
  
  describe "create_pair" do
  
    before(:each) do
      @field = {'as' => 'foopair', 'field_group_id' => 1, 'label' => 'Event'}
      @pair1 = {'name' => 'pair1'}
      @pair2 = {'name' => 'pair2'}
      @params  = { 'field' => @field, 'pair' => {'0' => @pair1, '1' => @pair2} }
    end
  
    it "should create the pair" do
      params1 = @field.merge(@pair1)
      foo1 = mock(:id => 3, :required => true, :disabled => 'false')
      CustomFieldFooPair.should_receive(:create).with( params1 ).and_return(foo1)
      params2 = @field.merge(@pair2).merge('pair_id' => 3, 'required' => true, 'disabled' => 'false')
      foo2 = mock(:id => 5)
      CustomFieldFooPair.should_receive(:create).with( params2 ).and_return(foo2)

      CustomFieldPair.create_pair(@params).should == [foo1, foo2]
    end
    
  end

  describe "update_pair" do
  
    before(:each) do
      @field = {'as' => 'foopair', 'field_group_id' => 1, 'label' => 'Event'}
      @pair1 = {'name' => 'pair1'}
      @pair2 = {'name' => 'pair2'}
      @params  = { 'id' => '3', 'field' => @field, 'pair' => {'0' => @pair1, '1' => @pair2} }
    end

    it "should update the pair" do
      foo1 = mock(:required => true, :disabled => 'false')
      foo1.should_receive(:update_attributes).with( @field.merge(@pair1) )
      foo2 = mock
      foo2.should_receive(:update_attributes).with( @field.merge(@pair2).merge('required' => true, 'disabled' => 'false') )
      foo1.should_receive(:paired_with).and_return(foo2)
      CustomFieldPair.should_receive(:find).with('3').and_return(foo1)

      CustomFieldPair.update_pair(@params).should == [foo1, foo2]
    end

  end
  
  describe "paired_with" do
  
    before(:each) do
      @field1 = CustomFieldDatePair.new(:name => 'cf_event_from')
      @field2 = CustomFieldDatePair.new(:name => 'cf_event_to')
    end
    
    it "should return the 2nd field" do
      @field1.should_receive(:pair).and_return(@field2)
      @field1.paired_with.should == @field2
    end
    
    it "should return the 1st field" do
      @field2.should_receive(:pair).and_return(nil)
      @field2.should_receive(:id).and_return(1)
      CustomFieldPair.should_receive(:where).with(:pair_id => 1).and_return([@field1])
      @field2.paired_with.should == @field1
    end

  end

end
