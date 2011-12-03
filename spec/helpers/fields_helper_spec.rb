require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include FieldsHelper

describe FieldsHelper do

  it "should be able to display a empty multi_select value" do
    field = Field.new(
      :label => "Availability",
      :name  => "availability"
    )
    object = mock('Object')

    #  as  |  value  |  expected
    [[ "check_boxes", [1, 2, 3],           "1, 2<br />3" ],
     [ "checkbox",    "0",                 "no" ],
     [ "checkbox",    1,                 "yes" ],
     [ "date",        Time.new(2011,4,19), "2011-04-19" ]].each do |as, value, expected|
      field.as = as
      object.stub!(field.name).and_return(value)
      display_value(object, field).should == expected
    end

  end
end

