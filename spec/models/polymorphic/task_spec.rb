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

  before { login }

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
        task = FactoryGirl.create(:task, :bucket => "specific_time", :calendar => "5/5/2020 12:00 AM")
        task.errors.should be_empty
        task.bucket.should == "specific_time"
        task.due_at.should == DateTime.parse("2020-05-05")
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
        task.update_attributes( { :bucket => "specific_time", :calendar => "05/05/2020 12:00 AM" } )
        task.errors.should be_empty
        task.bucket.should == "specific_time"
        task.due_at.should == DateTime.parse("2020-05-05")
      end
    end
  
  end
  
  describe "Task/Complete" do
    it "should comlete a task that is overdue" do
      task = FactoryGirl.create(:task, :due_at => 2.days.ago, :bucket => "overdue")
      task.update_attributes(:completed_at => Time.now, :completed_by => @current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == @current_user
    end
  
    it "should complete a task due sometime in the future" do
      task = FactoryGirl.create(:task, :due_at => Time.now.midnight.tomorrow, :bucket => "due_tomorrow")
      task.update_attributes(:completed_at => Time.now, :completed_by => @current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == @current_user
    end
  
    it "should complete a task that is due on specific date in the future" do
      task = FactoryGirl.create(:task, :calendar => "10/10/2022 12:00 AM", :bucket => "specific_time")
      task.calendar = nil # Calendar is not saved in the database; we need it only to set the :due_at.
      task.update_attributes(:completed_at => Time.now, :completed_by => @current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == @current_user
    end
  
    it "should complete a task that is due on specific date in the past" do
      task = FactoryGirl.create(:task, :calendar => "10/10/1992 12:00 AM", :bucket => "specific_time")
      task.calendar = nil # Calendar is not saved in the database; we need it only to set the :due_at.
      task.update_attributes(:completed_at => Time.now, :completed_by => @current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == @current_user
    end
  
    it "completion should preserve original due date" do
      due_at = 42.days.ago
      time_format = I18n.t(Setting.task_calendar_with_time ? 
                           'time.formats.mmddyyyy_hhmm' :
                           'date.formats.mmddyyyy')
      task = FactoryGirl.create(:task, :due_at => due_at, :bucket => "specific_time",
                            :calendar => due_at.strftime(time_format))
      task.update_attributes(:completed_at => Time.now, :completed_by => @current_user.id, :calendar => '')
      task.completed?.should == true
      parsed_time = DateTime.strptime(due_at.strftime(time_format), time_format).utc
      task.due_at.to_i.should == parsed_time.to_i
    end
  end
  
  # named_scope :my, lambda { |user| { :conditions => [ "(user_id = ? AND assigned_to IS NULL) OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  describe "task.my?" do
    it "should match a task created by the user" do
      task = FactoryGirl.create(:task, :user => @current_user, :assignee => nil)
      task.my?(@current_user).should == true
    end
  
    it "should match a task assigned to the user" do
      task = FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :assignee => @current_user)
      task.my?(@current_user).should == true
    end
  
    it "should Not match a task not created by the user" do
      task = FactoryGirl.create(:task, :user => FactoryGirl.create(:user))
      task.my?(@current_user).should == false
    end
  
    it "should Not match a task created by the user but assigned to somebody else" do
      task = FactoryGirl.create(:task, :user => @current_user, :assignee => FactoryGirl.create(:user))
      task.my?(@current_user).should == false
    end
  end
  
  # named_scope :assigned_by, lambda { |user| { :conditions => [ "user_id = ? AND assigned_to IS NOT NULL AND assigned_to != ?", user.id, user.id ], :include => :assignee } }
  describe "task.assigned_by?" do
    it "should match a task assigned by the user to somebody else" do
      task = FactoryGirl.create(:task, :user => @current_user, :assignee => FactoryGirl.create(:user))
      task.assigned_by?(@current_user).should == true
    end
  
    it "should Not match a task not created by the user" do
      task = FactoryGirl.create(:task, :user => FactoryGirl.create(:user))
      task.assigned_by?(@current_user).should == false
    end
  
    it "should Not match a task not assigned to anybody" do
      task = FactoryGirl.create(:task, :assignee => nil)
      task.assigned_by?(@current_user).should == false
    end
  
    it "should Not match a task assigned to the user" do
      task = FactoryGirl.create(:task, :assignee => @current_user)
      task.assigned_by?(@current_user).should == false
    end
  end
  
  # named_scope :tracked_by, lambda { |user| { :conditions => [ "user_id = ? OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  describe "task.tracked_by?" do
    it "should match a task created by the user" do
      task = FactoryGirl.create(:task, :user => @current_user)
      task.tracked_by?(@current_user).should == true
    end
  
    it "should match a task assigned to the user" do
      task = FactoryGirl.create(:task, :assignee => @current_user)
      task.tracked_by?(@current_user).should == true
    end
  
    it "should Not match a task that is neither created nor assigned to the user" do
      task = FactoryGirl.create(:task, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
      task.tracked_by?(@current_user).should == false
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
    before :each do
      I18n.locale = "de"
      @task = Task.new
      @task.bucket = "specific_time"
      @backup_with_time = Setting.task_calendar_with_time
    end
    
    after :each do
      I18n.locale = "en-Us"
      Setting.task_calendar_with_time = @backup_with_time
    end
    
    context "german" do
      context "date" do
        before :each do
          Setting.task_calendar_with_time = false
        end
        
        it "should translate: \"20 Jänner 2012\" to \"20 January 2012\"" do
          @task.calendar = "20 Jänner 2012"
          @task.send(:parse_calendar_date).should == "20 January 2012"
        end

        it "should translate: \"20 Februar 2012\" to \"20 February 2012\"" do
          @task.calendar = "20 Februar 2012"
          @task.send(:parse_calendar_date).should == "20 February 2012"
        end

        it "should translate: \"20 März 2012\" to \"20 March 2012\"" do
          @task.calendar = "20 März 2012"
          @task.send(:parse_calendar_date).should == "20 March 2012"
        end

        it "should translate: \"20 April 2012\" to \"20 April 2012\"" do
          @task.calendar = "20 April 2012"
          @task.send(:parse_calendar_date).should == "20 April 2012"
        end

        it "should translate: \"20 Mai 2012\" to \"20 May 2012\"" do
          @task.calendar = "20 Mai 2012"
          @task.send(:parse_calendar_date).should == "20 May 2012"
        end

        it "should translate: \"20 Juni 2012\" to \"20 June 2012\"" do
          @task.calendar = "20 Juni 2012"
          @task.send(:parse_calendar_date).should == "20 June 2012"
        end

        it "should translate: \"20 Juli 2012\" to \"20 July 2012\"" do
          @task.calendar = "20 Juli 2012"
          @task.send(:parse_calendar_date).should == "20 July 2012"
        end

        it "should translate: \"20 August 2012\" to \"20 August 2012\"" do
          @task.calendar = "20 August 2012"
          @task.send(:parse_calendar_date).should == "20 August 2012"
        end

        it "should translate: \"20 September 2012\" to \"20 September 2012\"" do
          @task.calendar = "20 September 2012"
          @task.send(:parse_calendar_date).should == "20 September 2012"
        end

        it "should translate: \"20 Oktober 2012\" to \"20 October 2012\"" do
          @task.calendar = "20 Oktober 2012"
          @task.send(:parse_calendar_date).should == "20 October 2012"
        end

        it "should translate: \"20 November 2012\" to \"20 November 2012\"" do
          @task.calendar = "20 November 2012"
          @task.send(:parse_calendar_date).should == "20 November 2012"
        end

        it "should translate: \"20 Dezember 2012\" to \"20 December 2012\"" do
          @task.calendar = "20 Dezember 2012"
          @task.send(:parse_calendar_date).should == "20 December 2012"
        end
      end
      
      context 'datetime' do
        before :each do
          Setting.task_calendar_with_time = true
        end
        
        it "should translate: \"20 Jänner 2012 12:27\" to \"20 January 2012 12:27\"" do
          @task.calendar = "20 Jänner 2012 12:27"
          @task.send(:parse_calendar_date).should == "20 January 2012 12:27"
        end
      end
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
    end

    context "by_due_at" do
      it "should show tasks ordered by due_at" do
        t1 = FactoryGirl.create(:task, :name => 't1', :bucket => "due_asap")
        t2 = FactoryGirl.create(:task, :calendar => 5.days.from_now.strftime("%m/%d/%Y %I:%M %p"), :bucket => "specific_time")
        t3 = FactoryGirl.create(:task, :name => 't3',  :bucket => "due_next_week")
        t4 = FactoryGirl.create(:task, :calendar => 20.days.from_now.strftime("%m/%d/%Y %I:%M %p"), :bucket => "specific_time")
        Task.by_due_at.should == [t1, t2, t3, t4]
      end
    end
  end
end

