require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
    Field.field_types['string'].should == {:type => :string, :options => nil}
  end
end

