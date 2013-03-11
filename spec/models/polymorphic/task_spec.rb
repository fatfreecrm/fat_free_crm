# encoding: utf-8
# == Schema Information
#
# Table name: tasks
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  assigned_to     :integer
#  completed_by    :integer
#  name            :string(255)     default(""), not null
#  asset_id        :integer
#  asset_type      :string(255)
#  priority        :string(32)
#  category        :string(32)
#  bucket          :string(32)
#  due_at          :datetime
#  completed_at    :datetime
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Task do

  let(:current_user) { FactoryGirl.create(:user) }

  describe "Task/Create" do
    it "should create a new task instance given valid attributes" do
      task = FactoryGirl.create(:task)
      task.should be_valid
      task.errors.should be_empty
    end
  
    [ nil, Time.now.utc_offset + 3600 ].each do |offset|
      before do
        adjust_timezone(offset)
      end
  
      it "should create a task with due date selected from dropdown within #{offset ? 'different' : 'current'} timezone" do
        task = FactoryGirl.create(:task, :due_at => Time.now.end_of_week, :bucket => "due_this_week")
        task.errors.should be_empty
        task.bucket.should == "due_this_week"
        task.due_at.should == Time.zone.now.end_of_week
      end
  
      it "should create a task with due date selected from the calendar within #{offset ? 'different' : 'current'} timezone" do
        task = FactoryGirl.create(:task, :bucket => "specific_time", :calendar => "2020-03-20")
        task.errors.should be_empty
        task.bucket.should == "specific_time"
        task.due_at.to_i.should == Time.parse("2020-03-20").to_i
      end
    end
  end
  
  describe "Task/Update" do
    it "should update task name" do
      task = FactoryGirl.create(:task, :name => "Hello")
      task.update_attributes({ :name => "World"})
      task.errors.should be_empty
      task.name.should == "World"
    end
  
    it "should update task category" do
      task = FactoryGirl.create(:task, :category => "call")
      task.update_attributes({ :category => "email" })
      task.errors.should be_empty
      task.category.should == "email"
    end
  
    it "should reassign the task to another person" do
      him = FactoryGirl.create(:user)
      her = FactoryGirl.create(:user)
      task = FactoryGirl.create(:task, :assigned_to => him.id)
      task.update_attributes( { :assigned_to => her.id } )
      task.errors.should be_empty
      task.assigned_to.should == her.id
      task.assignee.should == her
    end
  
    it "should reassign the task from another person to myself" do
      him = FactoryGirl.create(:user)
      task = FactoryGirl.create(:task, :assigned_to => him.id)
      task.update_attributes( { :assigned_to => "" } )
      task.errors.should be_empty
      task.assigned_to.should == nil
      task.assignee.should == nil
    end
  
    [ nil, Time.now.utc_offset + 3600 ].each do |offset|
      before do
        adjust_timezone(offset)
      end
  
      it "should update due date based on selected bucket within #{offset ? 'different' : 'current'} timezone" do
        task = FactoryGirl.create(:task, :due_at => Time.now.midnight.tomorrow, :bucket => "due_tomorrow")
        task.update_attributes( { :bucket => "due_this_week" } )
        task.errors.should be_empty
        task.bucket.should == "due_this_week"
        task.due_at.should == Time.zone.now.end_of_week
      end
  
      it "should update due date if specific calendar date selected within #{offset ? 'different' : 'current'} timezone" do
        task = FactoryGirl.create(:task, :due_at => Time.now.midnight.tomorrow, :bucket => "due_tomorrow")
        task.update_attributes( { :bucket => "specific_time", :calendar => "2020-03-20" } )
        task.errors.should be_empty
        task.bucket.should == "specific_time"
        task.due_at.to_i.should == Time.parse("2020-03-20").to_i
      end
    end
  
  end
  
  describe "Task/Complete" do
    it "should comlete a task that is overdue" do
      task = FactoryGirl.create(:task, :due_at => 2.days.ago, :bucket => "overdue")
      task.update_attributes(:completed_at => Time.now, :completed_by => current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == current_user
    end
  
    it "should complete a task due sometime in the future" do
      task = FactoryGirl.create(:task, :due_at => Time.now.midnight.tomorrow, :bucket => "due_tomorrow")
      task.update_attributes(:completed_at => Time.now, :completed_by => current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == current_user
    end
  
    it "should complete a task that is due on specific date in the future" do
      task = FactoryGirl.create(:task, :calendar => "10/10/2022 12:00 AM", :bucket => "specific_time")
      task.calendar = nil # Calendar is not saved in the database; we need it only to set the :due_at.
      task.update_attributes(:completed_at => Time.now, :completed_by => current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == current_user
    end
  
    it "should complete a task that is due on specific date in the past" do
      task = FactoryGirl.create(:task, :calendar => "10/10/1992 12:00 AM", :bucket => "specific_time")
      task.calendar = nil # Calendar is not saved in the database; we need it only to set the :due_at.
      task.update_attributes(:completed_at => Time.now, :completed_by => current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == current_user
    end
  
    it "completion should preserve original due date" do
      due_at = Time.now - 42.days
      task = FactoryGirl.create(:task, :due_at => due_at, :bucket => "specific_time",
                            :calendar => due_at.strftime('%Y-%m-%d %H:%M'))
      task.update_attributes(:completed_at => Time.now, :completed_by => current_user.id, :calendar => '')
      task.completed?.should == true
      task.due_at.should == due_at.utc.strftime('%Y-%m-%d %H:%M')
    end
  end
  
  # named_scope :my, lambda { |user| { :conditions => [ "(user_id = ? AND assigned_to IS NULL) OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  describe "task.my?" do
    it "should match a task created by the user" do
      task = FactoryGirl.create(:task, :user => current_user, :assignee => nil)
      task.my?(current_user).should == true
    end
  
    it "should match a task assigned to the user" do
      task = FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :assignee => current_user)
      task.my?(current_user).should == true
    end
  
    it "should Not match a task not created by the user" do
      task = FactoryGirl.create(:task, :user => FactoryGirl.create(:user))
      task.my?(current_user).should == false
    end
  
    it "should Not match a task created by the user but assigned to somebody else" do
      task = FactoryGirl.create(:task, :user => current_user, :assignee => FactoryGirl.create(:user))
      task.my?(current_user).should == false
    end
  end
  
  # named_scope :assigned_by, lambda { |user| { :conditions => [ "user_id = ? AND assigned_to IS NOT NULL AND assigned_to != ?", user.id, user.id ], :include => :assignee } }
  describe "task.assigned_by?" do
    it "should match a task assigned by the user to somebody else" do
      task = FactoryGirl.create(:task, :user => current_user, :assignee => FactoryGirl.create(:user))
      task.assigned_by?(current_user).should == true
    end
  
    it "should Not match a task not created by the user" do
      task = FactoryGirl.create(:task, :user => FactoryGirl.create(:user))
      task.assigned_by?(current_user).should == false
    end
  
    it "should Not match a task not assigned to anybody" do
      task = FactoryGirl.create(:task, :assignee => nil)
      task.assigned_by?(current_user).should == false
    end
  
    it "should Not match a task assigned to the user" do
      task = FactoryGirl.create(:task, :assignee => current_user)
      task.assigned_by?(current_user).should == false
    end
  end
  
  # named_scope :tracked_by, lambda { |user| { :conditions => [ "user_id = ? OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  describe "task.tracked_by?" do
    it "should match a task created by the user" do
      task = FactoryGirl.create(:task, :user => current_user)
      task.tracked_by?(current_user).should == true
    end
  
    it "should match a task assigned to the user" do
      task = FactoryGirl.create(:task, :assignee => current_user)
      task.tracked_by?(current_user).should == true
    end
  
    it "should Not match a task that is neither created nor assigned to the user" do
      task = FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
      task.tracked_by?(current_user).should == false
    end
  end
  
  describe "Exportable" do
    describe "unassigned tasks" do
      before do
        Task.delete_all
        FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :assignee => nil)
        FactoryGirl.create(:task, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Task.all }
      end
    end
  
    describe "assigned tasks" do
      before do
        Task.delete_all
        FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
        FactoryGirl.create(:task, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => FactoryGirl.create(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Task.all }
      end
    end
  
    describe "completed tasks" do
      before do
        Task.delete_all
        FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :completor => FactoryGirl.create(:user), :completed_at => 1.day.ago)
        FactoryGirl.create(:task, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :completor => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :completed_at => 1.day.ago)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Task.all }
      end
    end
  end
  
  describe "#parse_calendar_date" do

    it "should parse the date" do
      @task = Task.new(:calendar => '2020-12-23')
      Time.should_receive(:parse).with('2020-12-23')
      @task.send(:parse_calendar_date)
    end

  end

  describe "scopes" do
    context "visible_on_dashboard" do
      before :each do
        @user = FactoryGirl.create(:user)
        @t1 = FactoryGirl.create(:task, :user => @user)
        @t2 = FactoryGirl.create(:task, :user => @user, :assignee => FactoryGirl.create(:user))
        @t3 = FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :assignee => @user)
        @t4 = FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
        @t5 = FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :assignee => @user)
        @t6 = FactoryGirl.create(:completed_task, :assignee => @user)
      end

      it "should show tasks which have been created by the user and are unassigned" do
        Task.visible_on_dashboard(@user).should include(@t1)
      end

      it "should show tasks which are assigned to the user" do
        Task.visible_on_dashboard(@user).should include(@t3, @t5)
      end

      it "should not show tasks which are not assigned to the user" do
        Task.visible_on_dashboard(@user).should_not include(@t4)
      end

      it "should not show tasks which are created by the user but assigned" do
        Task.visible_on_dashboard(@user).should_not include(@t2)
      end

      it "should not include completed tasks" do
        Task.visible_on_dashboard(@user).should_not include(@t6)
      end
    end

    context "by_due_at" do
      it "should show tasks ordered by due_at" do
        t1 = FactoryGirl.create(:task, :name => 't1', :bucket => "due_asap")
        t2 = FactoryGirl.create(:task, :calendar => 5.days.from_now.strftime("%Y-%m-%d %H:%M"), :bucket => "specific_time")
        t3 = FactoryGirl.create(:task, :name => 't3',  :bucket => "due_next_week")
        t4 = FactoryGirl.create(:task, :calendar => 20.days.from_now.strftime("%Y-%m-%d %H:%M"), :bucket => "specific_time")
        Task.by_due_at.should == [t1, t2, t3, t4]
      end
    end
  end
end
