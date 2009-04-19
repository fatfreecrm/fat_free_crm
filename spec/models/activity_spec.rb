# == Schema Information
# Schema version: 17
#
# Table name: activities
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)
#  subject_id   :integer(4)
#  subject_type :string(255)
#  action       :string(32)      default("created")
#  info         :string(255)     default("")
#  private      :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Activity do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Activity.create!(:user => Factory(:user), :subject => Factory(:lead))
  end

  describe "with multiple activity records" do

    before(:each) do
      @user = Factory(:user)
      @actions = %w(created deleted updated viewed).freeze
      @actions.each_with_index do |action, index|
        Factory(:activity, :id => index + 1, :action => action, :user => @user, :subject => Factory(:lead))
        Factory(:activity, :action => action, :subject => Factory(:lead)) # different user
      end
    end

    it "should select all activities except one" do
      @activities = Activity.for(@user).except(:viewed)
      @activities.map(&:action).sort.should == %w(created deleted updated)
    end

    it "should select all activities except many" do
      @activities = Activity.for(@user).except(:created, :updated, :deleted)
      @activities.map(&:action).should == %w(viewed)
    end

    it "should select one requested activity" do
      @activities = Activity.for(@user).only(:deleted)
      @activities.map(&:action).should == %w(deleted)
    end

    it "should select many requested activities" do
      @activities = Activity.for(@user).only(:created, :updated)
      @activities.map(&:action).sort.should == %w(created updated)
    end

    it "should select activities for given user" do
      @activities = Activity.for(@user)
      @activities.map(&:action).sort.should == @actions
    end

  end

  %w(account campaign contact lead opportunity task).each do |subject|
    it "should add an activity when creating new #{subject}" do
      @subject = Factory(subject.to_sym)
      @activity = Activity.find(:first, :conditions => [ "subject_id=? AND subject_type=? AND action='created'", @subject.id, subject.capitalize ])

      @activity.should_not == nil
      @activity.info.should == (@subject.respond_to?(:full_name) ? @subject.full_name : @subject.name)
    end

    it "should add an activity when updating existing #{subject}" do
      @subject = Factory(subject.to_sym)
      if @subject.respond_to?(:full_name)
        @subject.update_attributes(:first_name => "Billy", :last_name => "Bones")
      else
        @subject.update_attributes(:name => "Billy Bones")
      end
      @activity = Activity.find(:first, :conditions => [ "subject_id=? AND subject_type=? AND action='updated'", @subject.id, subject.capitalize ])

      @activity.should_not == nil
      @activity.info.should == "Billy Bones"
    end

    it "should add an activity when deleting #{subject}" do
      @subject = Factory(subject.to_sym)
      @subject.destroy
      @activity = Activity.find(:first, :conditions => [ "subject_id=? AND subject_type=? AND action='deleted'", @subject.id, subject.capitalize ])

      @activity.should_not == nil
      @activity.info.should == (@subject.respond_to?(:full_name) ? @subject.full_name : @subject.name)
    end
    
    it "should add an activity when commenting on a #{subject}" do
      @subject = Factory(subject.to_sym)
      @comment = Factory(:comment, :commentable => @subject)

      @activity = Activity.find(:first, :conditions => [ "subject_id=? AND subject_type=? AND action='commented'", @subject.id, subject.capitalize ])
      @activity.should_not == nil
      @activity.info.should == (@subject.respond_to?(:full_name) ? @subject.full_name : @subject.name)
    end
  
  end

  %w(account campaign contact lead opportunity).each do |subject|
    before(:each) do
      @subject = Factory(subject.to_sym)
      @conditions = [ "subject_id=? AND subject_type=? AND action='viewed'", @subject.id, subject.capitalize ]
    end

    it "creating a new #{subject} should also make it a recently viewed item" do
      @activity = Activity.first(:conditions => @conditions)

      @activity.should_not == nil
    end

    it "updating #{subject} should also mark it as recently viewed" do
      @before = Activity.first(:conditions => @conditions)
      if @subject.respond_to?(:full_name)
        @subject.update_attributes(:first_name => "Billy", :last_name => "Bones")
      else
        @subject.update_attributes(:name => "Billy Bones")
      end
      @after = Activity.first(:conditions => @conditions)

      @before.should_not == nil
      @after.should_not == nil
      @after.updated_at.should >= @before.updated_at
    end

    it "deleting #{subject} should remove it from recently viewed items" do
      @subject.destroy
      @activity = Activity.first(:conditions => @conditions)

      @activity.should be_nil
    end
  end

end
