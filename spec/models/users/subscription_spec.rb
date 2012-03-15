require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Subscription do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @contact = FactoryGirl.create(:contact)
  end

  it "should create a new instance given valid attributes" do
    Subscription.create!(:user => @user, :entity => @contact, :event_type => "comment")
  end

end
