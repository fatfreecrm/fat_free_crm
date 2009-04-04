# == Schema Information
# Schema version: 16
#
# Table name: tasks
#
#  id           :integer(4)      not null, primary key
#  uuid         :string(36)
#  user_id      :integer(4)
#  assigned_to  :integer(4)
#  name         :string(255)     default(""), not null
#  asset_id     :integer(4)
#  asset_type   :string(255)
#  priority     :string(32)
#  category     :string(32)
#  due_at_hint  :string(32)
#  due_at       :datetime
#  completed_at :datetime
#  deleted_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Task do

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

    it "should update due date based on hint" do
      task = Factory(:task, :due_at => Date.tomorrow, :due_at_hint => "due_tomorrow")
      task.update_attributes( { :due_at_hint => "due_this_week" } )
      task.due_at_hint.should == "due_this_week"
      task.due_at.should == Date.today.end_of_week
    end

    it "should update due date based on specific date hint" do
      task = Factory(:task, :due_at => Date.tomorrow, :due_at_hint => "due_tomorrow")
      task.update_attributes( { :due_at_hint => "specific_time", :calendar => "01/31/2020" } )
      task.due_at_hint.should == "specific_time"
      task.due_at.should == Time.parse("01/31/2020")
    end

  end

end
