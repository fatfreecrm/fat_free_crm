require File.dirname(__FILE__) + '/spec_helper'

class FauxModelBase
  def self.add_observer(observer_instance); end
end

class Post < FauxModelBase; end
class Category < FauxModelBase; end
class Label < FauxModelBase; end

class FauxApplicationController  
  def self.cache_sweeper(sweepers); end
  
  def self.current_user
    User.new(220)
  end
end

class PostsController < FauxApplicationController
  extend UserStamp::ClassMethods
end

describe UserStamp::ClassMethods do
  before do
    UserStamp.creator_attribute   = :creator_id
    UserStamp.updater_attribute   = :updater_id
    UserStamp.current_user_method = :current_user
  end
  
  it "should add user_stamp method" do
    PostsController.respond_to?(:user_stamp).should == true
  end
  
  def user_stamp
    PostsController.user_stamp Post, Category, Label
  end
  
  describe "#user_stamp" do
    it "should add UserStampSweeper as observer for each model" do
      [Post, Category, Label].each do |klass|
        klass.should_receive(:add_observer).with(UserStampSweeper.instance).once
      end
      user_stamp
    end
    
    it "should setup cache sweeper for controller" do
      PostsController.should_receive(:cache_sweeper).with(:user_stamp_sweeper).once
      user_stamp
    end
  end
end