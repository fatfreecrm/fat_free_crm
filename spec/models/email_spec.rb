require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Email do
  before(:each) do
    @email = Email.new
  end

  it "should be valid" do
    @email.should be_valid
  end
end
