require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Permission do
  before(:each) do
    @valid_attributes = {
      :user => mock_model(User),
      :asset => mock_model(Account)
    }
  end

  it "should create a new instance given valid attributes" do
    Permission.create!(@valid_attributes)
  end
end
