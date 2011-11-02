require 'spec_helper'

describe Field do

  it "should create a new instance given valid attributes" do
    Field.create!(
      :name => 'skype_address',
      :label => 'Skype address',
      :field_type => 'short_answer',
      :max_size => 220,
      :position => 10
    )
  end

  it "should be able to use a field_type to set defined values" do
    c = Field.new
    c.field_type = "number"
    c.column_type.should == "DECIMAL"
    c.display_width.should == 60

    c.field_type = "short_answer"
    c.column_type.should == "TEXT"
    c.display_width.should == 200
  end

  it "should be able to display a empty multi_select value" do
    field = Field.new
    field.field_type = "multi_select"
    field.label = "Availability"
    field.name = "availability"
    object = mock('Object')
    object.stub!(:availability, "")

    field.display_value(object).should == ""
  end
end
