# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
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

require 'spec_helper'

describe Task do

  let!(:current_user) { create :user }

  describe "Task/Create" do
    it "should create a new task instance given valid attributes" do
      task = create(:task)
      task.should be_valid
      task.errors.should be_empty
    end

    [ nil, Time.now.utc_offset + 3600 ].each do |offset|
      before do
        adjust_timezone(offset)
      end

      it "should create a task with due date selected from dropdown within #{offset ? 'different' : 'current'} timezone" do
        task = create(:task, due_at: Time.now.end_of_week, bucket: "due_this_week")
        task.errors.should be_empty
        task.bucket.should == "due_this_week"
        task.due_at.should == Time.zone.now.end_of_week
      end

      it "should create a task with due date selected from the calendar within #{offset ? 'different' : 'current'} timezone" do
        task = create(:task, bucket: "specific_time", calendar: "2020-03-20")
        task.errors.should be_empty
        task.bucket.should == "specific_time"
        task.due_at.to_i.should == Time.parse("2020-03-20").to_i
      end
    end
  end

  describe "Task/Update" do
    it "should update task name" do
      task = create(:task, name: "Hello")
      task.update_attributes({ name: "World"})
      task.errors.should be_empty
      task.name.should == "World"
    end

    it "should update task category" do
      task = create(:task, category: "call")
      task.update_attributes({ category: "email" })
      task.errors.should be_empty
      task.category.should == "email"
    end

    it "should reassign the task to another person" do
      him = create(:user)
      her = create(:user)
      task = create(:task, assigned_to: him.id)
      task.update_attributes( { assigned_to: her.id } )
      task.errors.should be_empty
      task.assigned_to.should == her.id
      task.assignee.should == her
    end

    it "should reassign the task from another person to myself" do
      him = create(:user)
      task = create(:task, assigned_to: him.id)
      task.update_attributes( { assigned_to: "" } )
      task.errors.should be_empty
      task.assigned_to.should == nil
      task.assignee.should == nil
    end

    [ nil, Time.now.utc_offset + 3600 ].each do |offset|
      before do
        adjust_timezone(offset)
      end

      it "should update due date based on selected bucket within #{offset ? 'different' : 'current'} timezone" do
        task = create(:task, due_at: Time.now.midnight.tomorrow, bucket: "due_tomorrow")
        task.update_attributes( { bucket: "due_this_week" } )
        task.errors.should be_empty
        task.bucket.should == "due_this_week"
        task.due_at.should == Time.zone.now.end_of_week
      end

      it "should update due date if specific calendar date selected within #{offset ? 'different' : 'current'} timezone" do
        task = create(:task, due_at: Time.now.midnight.tomorrow, bucket: "due_tomorrow")
        task.update_attributes( { bucket: "specific_time", calendar: "2020-03-20" } )
        task.errors.should be_empty
        task.bucket.should == "specific_time"
        task.due_at.to_i.should == Time.parse("2020-03-20").to_i
      end
    end

  end

  describe "Task/Complete" do
    it "should comlete a task that is overdue" do
      task = create(:task, due_at: 2.days.ago, bucket: "overdue")
      task.update_attributes(completed_at: Time.now, completed_by: current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == current_user
    end

    it "should complete a task due sometime in the future" do
      task = create(:task, due_at: Time.now.midnight.tomorrow, bucket: "due_tomorrow")
      task.update_attributes(completed_at: Time.now, completed_by: current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == current_user
    end

    it "should complete a task that is due on specific date in the future" do
      task = create(:task, calendar: "10/10/2022 12:00 AM", bucket: "specific_time")
      task.calendar = nil # Calendar is not saved in the database; we need it only to set the :due_at.
      task.update_attributes(completed_at: Time.now, completed_by: current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == current_user
    end

    it "should complete a task that is due on specific date in the past" do
      task = create(:task, calendar: "10/10/1992 12:00 AM", bucket: "specific_time")
      task.calendar = nil # Calendar is not saved in the database; we need it only to set the :due_at.
      task.update_attributes(completed_at: Time.now, completed_by: current_user.id)
      task.errors.should be_empty
      task.completed_at.should_not == nil
      task.completor.should == current_user
    end

    it "completion should preserve original due date" do
      due_at = Time.now - 42.days
      task = create(:task, due_at: due_at, bucket: "specific_time",
                            calendar: due_at.strftime('%Y-%m-%d %H:%M'))
      task.update_attributes(completed_at: Time.now, completed_by: current_user.id, calendar: '')
      task.completed?.should == true
      task.due_at.should == due_at.utc.strftime('%Y-%m-%d %H:%M')
    end
  end

  # named_scope :my, lambda { |user| { conditions: [ "(user_id = ? AND assigned_to IS NULL) OR assigned_to = ?", user.id, user.id ], include: :assignee } }
  describe "task.my?" do
    it "should match a task created by the user" do
      task = create(:task, user: current_user, assignee: nil)
      task.my?(current_user).should == true
    end

    it "should match a task assigned to the user" do
      task = create(:task, user: create(:user), assignee: current_user)
      task.my?(current_user).should == true
    end

    it "should Not match a task not created by the user" do
      task = create(:task, user: create(:user))
      task.my?(current_user).should == false
    end

    it "should Not match a task created by the user but assigned to somebody else" do
      task = create(:task, user: current_user, assignee: create(:user))
      task.my?(current_user).should == false
    end
  end

  # named_scope :assigned_by, lambda { |user| { conditions: [ "user_id = ? AND assigned_to IS NOT NULL AND assigned_to != ?", user.id, user.id ], include: :assignee } }
  describe "task.assigned_by?" do
    it "should match a task assigned by the user to somebody else" do
      task = create(:task, user: current_user, assignee: create(:user))
      task.assigned_by?(current_user).should == true
    end

    it "should Not match a task not created by the user" do
      task = create(:task, user: create(:user))
      task.assigned_by?(current_user).should == false
    end

    it "should Not match a task not assigned to anybody" do
      task = create(:task, assignee: nil)
      task.assigned_by?(current_user).should == false
    end

    it "should Not match a task assigned to the user" do
      task = create(:task, assignee: current_user)
      task.assigned_by?(current_user).should == false
    end
  end

  # named_scope :tracked_by, lambda { |user| { conditions: [ "user_id = ? OR assigned_to = ?", user.id, user.id ], include: :assignee } }
  describe "task.tracked_by?" do
    it "should match a task created by the user" do
      task = create(:task, user: current_user)
      task.tracked_by?(current_user).should == true
    end

    it "should match a task assigned to the user" do
      task = create(:task, assignee: current_user)
      task.tracked_by?(current_user).should == true
    end

    it "should Not match a task that is neither created nor assigned to the user" do
      task = create(:task, user: create(:user), assignee: create(:user))
      task.tracked_by?(current_user).should == false
    end
  end

  describe "task.computed_bucket" do

    context "when overdue" do
      subject { described_class.new(due_at: 1.days.ago, bucket: "specific_time") }

      it "returns a sensible value" do
        subject.computed_bucket.should == "overdue"
      end
    end

    context "when due today" do
      subject { described_class.new(due_at: Time.now, bucket: "specific_time") }

      it "returns a sensible value" do
        subject.computed_bucket.should == "due_today"
      end
    end

    context "when due tomorrow" do
      subject { described_class.new(due_at: 1.days.from_now.end_of_day, bucket: "specific_time") }

      it "returns a sensible value" do
        subject.computed_bucket.should == "due_tomorrow"
      end
    end

    context "when due this week" do
      it "returns a sensible value" do
        # Freeze time so tests will pass when run at the end of the week!!
        Timecop.freeze(Time.local(2014, 1, 1, 16, 14)) do
          task = described_class.new(due_at: Time.zone.now.end_of_week, bucket: "specific_time")
          expect(task.computed_bucket).to eql("due_this_week")
        end
      end
    end

    context "when due next week" do
      subject { described_class.new(due_at: Time.zone.now.next_week, bucket: "specific_time") }

      it "returns a sensible value" do
        subject.computed_bucket.should == "due_next_week"
      end
    end

    context "when due later" do
      subject { described_class.new(due_at: 1.month.from_now, bucket: "specific_time") }

      it "returns a sensible value" do
        subject.computed_bucket.should == "due_later"
      end
    end
  end

  describe "task.at_specific_time?" do
    context "when the due date is at the beginning of the day" do
      subject { described_class.new(due_at: Time.zone.now.beginning_of_day) }

      it "returns false" do
        subject.at_specific_time?.should == false
      end
    end

    context "when the due date is at the end of the day" do
      subject { described_class.new(due_at: Time.zone.now.end_of_day) }

      it "returns false" do
        subject.at_specific_time?.should == false
      end
    end

    context "when the due date is any other time" do
      subject { described_class.new(due_at: Time.zone.parse("2014-01-01 18:36:43")) }

      it "returns true" do
        subject.at_specific_time?.should == true
      end
    end
  end

  describe "Exportable" do
    describe "unassigned tasks" do
      before do
        Task.delete_all
        create(:task, user: create(:user), assignee: nil)
        create(:task, user: create(:user, first_name: nil, last_name: nil), assignee: nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Task.all }
      end
    end

    describe "assigned tasks" do
      before do
        Task.delete_all
        create(:task, user: create(:user), assignee: create(:user))
        create(:task, user: create(:user, first_name: nil, last_name: nil), assignee: create(:user, first_name: nil, last_name: nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Task.all }
      end
    end

    describe "completed tasks" do
      before do
        Task.delete_all
        create(:task, user: create(:user), completor: create(:user), completed_at: 1.day.ago)
        create(:task, user: create(:user, first_name: nil, last_name: nil), completor: create(:user, first_name: nil, last_name: nil), completed_at: 1.day.ago)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Task.all }
      end
    end
  end

  describe "#parse_calendar_date" do

    it "should parse the date" do
      @task = Task.new(calendar: '2020-12-23')
      Time.should_receive(:parse).with('2020-12-23')
      @task.send(:parse_calendar_date)
    end

  end

  describe "scopes" do
    context "visible_on_dashboard" do
      before :each do
        @user = create(:user)
        @t1 = create(:task, user: @user)
        @t2 = create(:task, user: @user, assignee: create(:user))
        @t3 = create(:task, user: create(:user), assignee: @user)
        @t4 = create(:task, user: create(:user), assignee: create(:user))
        @t5 = create(:task, user: create(:user), assignee: @user)
        @t6 = create(:completed_task, assignee: @user)
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
        t1 = create(:task, name: 't1', bucket: "due_asap")
        t2 = create(:task, calendar: 5.days.from_now.strftime("%Y-%m-%d %H:%M"), bucket: "specific_time")
        t3 = create(:task, name: 't3',  bucket: "due_next_week")
        t4 = create(:task, calendar: 20.days.from_now.strftime("%Y-%m-%d %H:%M"), bucket: "specific_time")
        Task.by_due_at.should == [t1, t2, t3, t4]
      end
    end
  end
end
