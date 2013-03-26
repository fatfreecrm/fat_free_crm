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
    CustomField.connection.should_receive(:add_column).
                with("contacts", "cf_test_field", 'string', {})
    Contact.should_receive(:reset_column_information)
    Contact.should_receive(:serialize_custom_fields!)

    FactoryGirl.create(:custom_field,
                       :as => "string",
                       :name => "cf_test_field",
                       :label => "Test Field",
                       :field_group => FactoryGirl.create(:field_group, :klass_name => "Contact"))
  end

  it "should generate a unique column name for a custom field" do
    field_group = FactoryGirl.build(:field_group, :klass_name => "Contact")
    c = FactoryGirl.build(:custom_field, :label => "Test Field", :field_group => field_group)

    columns = []
    %w(cf_test_field cf_test_field_2 cf_test_field_3 cf_test_field_4).each do |field|
      c.send(:generate_column_name).should == field
      c.stub!(:klass_column_names).and_return( columns << field )
    end

  end

  it "should evaluate the safety of database transitions" do
    c = FactoryGirl.build(:custom_field, :as => "string")
    c.send(:db_transition_safety, c.as, "email").should == :null
    c.send(:db_transition_safety, c.as, "text").should == :safe
    c.send(:db_transition_safety, c.as, "datetime").should == :unsafe

    c = FactoryGirl.build(:custom_field, :as => "datetime")
    c.send(:db_transition_safety, c.as, "date").should == :safe
    c.send(:db_transition_safety, c.as, "url").should == :unsafe
  end

  it "should return a safe list of types for the 'as' select options" do
    {"email"   => %w(check_boxes text string email url tel select radio),
     "integer" => %w(integer float)}.each do |type, expected_arr|
      c = FactoryGirl.build(:custom_field, :as => type)
      opts = c.available_as
      opts.map(&:first).should =~ expected_arr
    end
  end

  it "should change a column's type for safe transitions" do
    CustomField.connection.should_receive(:add_column).
                with("contacts", "cf_test_field", 'string', {})
    CustomField.connection.should_receive(:change_column).
                with("contacts", "cf_test_field", 'text', {})
    Contact.should_receive(:reset_column_information).twice
    Contact.should_receive(:serialize_custom_fields!).twice
    
    field_group = FactoryGirl.create(:field_group, :klass_name => "Contact")
    c = FactoryGirl.create(:custom_field,
                           :label => "Test Field",
                           :name => nil,
                           :as => "email",
                           :field_group => field_group)
    c.as = "text"
    c.save
  end

  describe "in case a new custom field was added by a different instance" do
    it "should refresh column info and retry on assignment error" do
      Contact.should_receive(:reset_column_information)

      lambda { Contact.new :cf_unknown_field => 123 }.should raise_error(ActiveRecord::UnknownAttributeError)
    end

    it "should refresh column info and retry on attribute error" do
      Contact.should_receive(:reset_column_information)
      Contact.should_receive(:serialize_custom_fields!)

      contact = FactoryGirl.build(:contact)
      contact.cf_another_new_field.should == nil
    end
  end

  describe "validation" do
  
    it "should have errors if custom field is required" do
      event = CustomField.new(:name => 'cf_event', :required => true)
      foo = mock(:cf_event => nil)
      err = mock(:errors); err.stub(:add)
      foo.should_receive(:errors).and_return(err)
      event.custom_validator(foo)
    end
    
    it "should have errors if custom field is longer than maxlength" do
      event = CustomField.new(:name => 'cf_event', :maxlength => 5)
      foo = mock(:cf_event => "This is too long")
      err = mock(:errors); err.stub(:add)
      foo.should_receive(:errors).and_return(err)
      event.custom_validator(foo)
    end
    
  end
  
end
