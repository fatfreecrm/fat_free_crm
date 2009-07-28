# == Schema Information
# Schema version: 21
#
# Table name: tasks
#
#  id           :integer(4)      not null, primary key
#  uuid         :string(36)
#  user_id      :integer(4)
#  assigned_to  :integer(4)
#  completed_by :integer(4)
#  name         :string(255)     default(""), not null
#  asset_id     :integer(4)
#  asset_type   :string(255)
#  priority     :string(32)
#  category     :string(32)
#  bucket       :string(32)
#  due_at       :datetime
#  completed_at :datetime
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Task do

  before(:each) do
    login
  end

  describe "Task/Create" do
    it "should create a new task instance given valid attributes" do
      task = Factory(:task)
      task.should be_valid
    end
  end

  describe "Task/Update" do
    it "should update task name" do
      task = Factory(:task, :name => "Hello")
      task.update_attributes({ :name => "World"})
      task.name.should == "World"
    end

    it "should update task category" do
      task = Factory(:task, :category => "call")
      task.update_attributes({ :category => "email" })
      task.category.should == "email"
    end

    it "should reassign the task to another person" do
      him = Factory(:user)
      her = Factory(:user)
      task = Factory(:task, :assigned_to => him.id)
      task.update_attributes( { :assigned_to => her.id } )
      task.assigned_to.should == her.id
      task.assignee.should == her
    end

    it "should reassign the task from another person to myself" do
      him = Factory(:user)
      task = Factory(:task, :assigned_to => him.id)
      task.update_attributes( { :assigned_to => "" } )
      task.assigned_to.should == nil
      task.assignee.should == nil
    end

    it "should update due date based on selected bucket" do
      task = Factory(:task, :due_at => Time.now.midnight.tomorrow, :bucket => "due_tomorrow")
      task.update_attributes( { :bucket => "due_this_week" } )
      task.bucket.should == "due_this_week"
      task.due_at.should == Time.now.end_of_week
    end

    it "should update due date if specific calendar date selected" do
      task = Factory(:task, :due_at => Time.now.midnight.tomorrow, :bucket => "due_tomorrow")
      task.update_attributes( { :bucket => "specific_time", :calendar => "01/31/2020" } )
      task.bucket.should == "specific_time"
      task.due_at.should == Time.zone.parse("01/31/2020")
    end

  end

  # named_scope :my, lambda { |user| { :conditions => [ "(user_id = ? AND assigned_to IS NULL) OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  describe "task.my?" do
    it "should match a task created by the user" do
      task = Factory(:task, :user => @current_user, :assignee => nil)
      task.my?(@current_user).should == true
    end

    it "should match a task assigned to the user" do
      task = Factory(:task, :user => Factory(:user), :assignee => @current_user)
      task.my?(@current_user).should == true
    end

    it "should Not match a task not created by the user" do
      task = Factory(:task, :user => Factory(:user))
      task.my?(@current_user).should == false
    end

    it "should Not match a task created by the user but assigned to somebody else" do
      task = Factory(:task, :user => @current_user, :assignee => Factory(:user))
      task.my?(@current_user).should == false
    end
  end

  # named_scope :assigned_by, lambda { |user| { :conditions => [ "user_id = ? AND assigned_to IS NOT NULL AND assigned_to != ?", user.id, user.id ], :include => :assignee } }
  describe "task.assigned_by?" do
    it "should match a task assigned by the user to somebody else" do
      task = Factory(:task, :user => @current_user, :assignee => Factory(:user))
      task.assigned_by?(@current_user).should == true
    end

    it "should Not match a task not created by the user" do
      task = Factory(:task, :user => Factory(:user))
      task.assigned_by?(@current_user).should == false
    end

    it "should Not match a task not assigned to anybody" do
      task = Factory(:task, :assignee => nil)
      task.assigned_by?(@current_user).should == false
    end

    it "should Not match a task assigned to the user" do
      task = Factory(:task, :assignee => @current_user)
      task.assigned_by?(@current_user).should == false
    end
  end

  # named_scope :tracked_by, lambda { |user| { :conditions => [ "user_id = ? OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  describe "task.tracked_by?" do
    it "should match a task created by the user" do
      task = Factory(:task, :user => @current_user)
      task.tracked_by?(@current_user).should == true
    end

    it "should match a task assigned to the user" do
      task = Factory(:task, :assignee => @current_user)
      task.tracked_by?(@current_user).should == true
    end

    it "should Not match a task that is neither created nor assigned to the user" do
      task = Factory(:task, :user => Factory(:user), :assignee => Factory(:user))
      task.tracked_by?(@current_user).should == false
    end
  end

end
