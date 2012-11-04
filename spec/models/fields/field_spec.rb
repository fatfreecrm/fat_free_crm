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

describe Field do

  it "should create a new instance given valid attributes" do
    Field.create!(
      :name      => 'skype_address',
      :label     => 'Skype address',
      :as        => 'string',
      :maxlength => 220,
      :position  => 10
    )
  end


  it "should return a list of field types" do
    Field.field_types['string'].should == {'klass' => 'CustomField', 'type' => 'string'}
  end

  it "should return a hash of input options" do
    Field.new.input_options.should be_a(Hash)
  end

  it "should be able to display a empty multi_select value" do
    field = Field.new(
      :label => "Availability",
      :name  => "availability"
    )
    object = mock('Object')

    #  as  |  value  |  expected
    [["check_boxes", [1, 2, 3],               "1, 2<br />3"],
     ["checkbox",    "0",                     "no"],
     ["checkbox",    1,                       "yes"],
     ["date",        DateTime.new(2011,4,19), DateTime.new(2011,4,19).strftime(I18n.t("date.formats.mmddyy")) ]].each do |as, value, expected|
      field.as = as
      object.stub!(field.name).and_return(value)
      field.render_value(object).should == expected
    end
  end
end
