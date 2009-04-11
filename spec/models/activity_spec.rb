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
    Authentication.stub!(:find).and_return(@authentication)
    @authentication.stub!(:record).and_return(Factory(:user))
  end

  it "should create a new instance given valid attributes" do
    Activity.create!(:user => Factory(:user), :subject => Factory(:lead))
  end

  %w(account campaign comment contact lead opportunity task).each do |subject|
    it "should add an activity when creating new #{subject}" do
      if subject == "comment"
        @subject = Factory(:comment, :commentable => Factory(:account))
      else
        @subject = Factory(subject.to_sym)
      end
      @activity = Activity.find(:first, :conditions => [ "subject_id=? AND subject_type=? AND action='created'", @subject.id, subject.capitalize ])
  
      @activity.should_not == nil
      @activity.info.should == (@subject.respond_to?(:full_name) ? @subject.full_name : @subject.name)
    end
  
    it "should add an activity when updating existing #{subject}" do
      if subject == "comment"
        @subject = Factory(:comment, :commentable => Factory(:account))
        @subject.update_attributes(:comment => "Billy Bones")
      else
        @subject = Factory(subject.to_sym)
        if @subject.respond_to?(:full_name)
          @subject.update_attributes(:first_name => "Billy", :last_name => "Bones")
        else
          @subject.update_attributes(:name => "Billy Bones")
        end
      end
      @activity = Activity.find(:first, :conditions => [ "subject_id=? AND subject_type=? AND action='updated'", @subject.id, subject.capitalize ])
  
      @activity.should_not == nil
      @activity.info.should == "Billy Bones"
    end
  
    it "should add an activity when deleting #{subject}" do
      if subject == "comment"
        @subject = Factory(:comment, :commentable => Factory(:account))
      else
        @subject = Factory(subject.to_sym)
      end
      @subject.destroy
      @activity = Activity.find(:first, :conditions => [ "subject_id=? AND subject_type=? AND action='deleted'", @subject.id, subject.capitalize ])
  
      @activity.should_not == nil
      @activity.info.should == (@subject.respond_to?(:full_name) ? @subject.full_name : @subject.name)
    end
  end

end
