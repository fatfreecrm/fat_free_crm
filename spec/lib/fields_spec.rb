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
    Foo.new.should respond_to(:field_groups)
  end
  
  it do
    Foo.should respond_to(:serialize_custom_fields!)
  end
  
  it do
    Foo.should respond_to(:fields)
  end
  
  it "calling has_fields should invoke serialize_custom_fields!" do
    Bar.should_receive(:serialize_custom_fields!)
    Bar.has_fields
  end
  
  describe "field_groups" do
  
    it "should call FieldGroup" do
      ActiveRecord::Base.connection.should_receive(:table_exists?).with('field_groups').and_return(true)
      dummy_scope = mock
      dummy_scope.should_receive(:order).with(:position)
      FieldGroup.should_receive(:where).and_return(dummy_scope)
      Foo.new.field_groups
    end
    
    it "should not call FieldGroup if table doesn't exist (migrations not yet run)" do
      ActiveRecord::Base.connection.should_receive(:table_exists?).with('field_groups').and_return(false)
      Foo.new.field_groups.should == []
    end
  
  end
  
  describe "fields" do
    
    before(:each) do
      @f1 = mock(Field)
      @f2 = mock(Field)
      @f3 = mock(Field)
      @field_groups = [mock(FieldGroup, :fields => [@f1, @f2]), mock(FieldGroup, :fields => [@f3])]
    end
  
    it "should convert field_groups into a flattened list of fields" do
      Foo.should_receive(:field_groups).and_return(@field_groups)
      Foo.fields.should == [@f1, @f2, @f3]
    end
  
  end
  
  describe "serialize_custom_fields!" do
  
    before(:each) do
      @f1 = mock(Field, :as => 'check_boxes', :name => 'field1')
      @f2 = mock(Field, :as => 'date', :name => 'field2')
    end
    
    it "should serialize checkbox fields as Array" do
      Foo.stub(:serialized_attributes).and_return( {:field1 => @f1, :field2 => @f2} )
      Foo.should_receive(:fields).and_return([@f1, @f2])
      Foo.should_receive(:serialize).with(:field1, Array)
      Foo.serialize_custom_fields!
    end
  
  end
  
  it "should validate custom fields" do
    foo = Foo.new
    foo.should_receive(:custom_fields_validator)
    foo.should be_valid
  end
  
  describe "custom_fields_validator" do
  
    before(:each) do
      @f1 = mock(Field)
      @field_groups = [ mock(FieldGroup, :fields => [@f1]) ]
    end
  
    it "should call custom_validator on each custom field" do
      foo = Foo.new
      @f1.should_receive(:custom_validator).with(foo)
      foo.should_receive(:field_groups).and_return(@field_groups)
      foo.should be_valid
    end

  end
  
end
