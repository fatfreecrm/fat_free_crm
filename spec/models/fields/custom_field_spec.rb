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
                with("contacts", "cf_test_field", :string, {})

    c = FactoryGirl.create(:custom_field,
                       :as => "string",
                       :name => "cf_test_field",
                       :label => "Test Field",
                       :field_group => FactoryGirl.create(:field_group, :klass_name => "Contact"))
  end

  it "should generate a unique column name for a custom field" do
    c = FactoryGirl.build(:custom_field, :label => "Test Field", :field_group => FactoryGirl.create(:field_group, :klass_name => "Contact"))

    # Overwrite :klass_column_names with instance variable accessors
    c.class_eval { attr_accessor :klass_column_names }
    c.klass_column_names = []

    %w(cf_test_field cf_test_field_2 cf_test_field_3).each do |expected|
      c.send(:generate_column_name).should == expected
      c.klass_column_names << expected
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

  # Find ActiveRecord column by name
  def ar_column(custom_field, column)
    custom_field.klass.columns.detect{|c| c.name == column }
  end

  it "should change a column's type for safe transitions" do
    CustomField.connection.should_receive(:add_column).
                with("contacts", "cf_test_field", :string, {})
    CustomField.connection.should_receive(:change_column).
                with("contacts", "cf_test_field", :text, {})

    c = FactoryGirl.create(:custom_field,
                       :label => "Test Field",
                       :name => nil,
                       :as => "email",
                       :field_group => FactoryGirl.create(:field_group, :klass_name => "Contact"))
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

      contact = FactoryGirl.build(:contact)
      contact.cf_another_new_field.should == nil
    end
  end
end

