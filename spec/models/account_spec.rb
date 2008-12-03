require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Account do
  before(:each) do
    @valid_attributes = {
      :name => "Test Account",
      :user => mock_model(User)
    }
  end

  it "should create a new instance given valid attributes" do
    Account.create!(@valid_attributes)
  end
end
