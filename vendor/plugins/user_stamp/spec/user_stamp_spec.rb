require File.dirname(__FILE__) + '/spec_helper'

describe UserStamp do
  before do
    UserStamp.creator_attribute   = :creator_id
    UserStamp.updater_attribute   = :updater_id
    UserStamp.current_user_method = :current_user
  end
  
  it "should default creator_attribute to creator_id" do
    UserStamp.creator_attribute.should == :creator_id
  end

  it "should default updater_attribute to updater_id" do
    UserStamp.updater_attribute.should == :updater_id
  end
  
  it "should default current_user_method to current_user" do
    UserStamp.current_user_method.should == :current_user
  end
  
  it "should have accessor for creator_attribute" do
    UserStamp.creator_attribute = 'mofo_id'
    UserStamp.creator_attribute.should == 'mofo_id'
  end
  
  it "should have accessor for updater_attribute" do
    UserStamp.updater_attribute = 'mofo_id'
    UserStamp.updater_attribute.should == 'mofo_id'
  end
  
  it "should have accessor for current_user_method" do
    UserStamp.current_user_method = 'my_current_user'
    UserStamp.current_user_method.should == 'my_current_user'
  end
  
  describe "assignment methods" do
    before do
      UserStamp.creator_attribute = 'creator_mofo_id'
      UserStamp.updater_attribute = 'updater_mofo_id'
    end
    
    it "should include creator assignment method" do
      UserStamp.creator_assignment_method.should == 'creator_mofo_id='
    end
    
    it "should include updater assignment method" do
      UserStamp.updater_assignment_method.should == 'updater_mofo_id='
    end
  end
end