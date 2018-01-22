# frozen_string_literal: true

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
  describe "Task/Create" do
    it "should create a new task instance given valid attributes" do
      task = create(:task)
      expect(task).to be_valid
      expect(task.errors).to be_empty
    end

    [nil, Time.now.utc_offset + 3600].each do |offset|
      before do
        adjust_timezone(offset)
      end

      it "should create a task with due date selected from dropdown within #{offset ? 'different' : 'current'} timezone" do
        task = create(:task, due_at: Time.now.end_of_week, bucket: "due_this_week")
        expect(task.errors).to be_empty
        expect(task.bucket).to eq("due_this_week")
        expect(task.due_at.change(usec: 0)).to eq(Time.zone.now.end_of_week.change(usec: 0))
      end

      it "should create a task with due date selected from the calendar within #{offset ? 'different' : 'current'} timezone" do
        task = create(:task, bucket: "specific_time", calendar: "2020-03-20")
        expect(task.errors).to be_empty
        expect(task.bucket).to eq("specific_time")
        expect(task.due_at.to_i).to eq(Time.parse("2020-03-20").to_i)
      end
    end
  end

  describe "Task/Update" do
    it "should update task name" do
      task = create(:task, name: "Hello")
      task.update_attributes(name: "World")
      expect(task.errors).to be_empty
      expect(task.name).to eq("World")
    end

    it "should update task category" do
      task = create(:task, category: "call")
      task.update_attributes(category: "email")
      expect(task.errors).to be_empty
      expect(task.category).to eq("email")
    end

    it "should reassign the task to another person" do
      him = create(:user)
      her = create(:user)
      task = create(:task, assigned_to: him.id)
      task.update_attributes(assigned_to: her.id)
      expect(task.errors).to be_empty
      expect(task.assigned_to).to eq(her.id)
      expect(task.assignee).to eq(her)
    end

    it "should reassign the task from another person to myself" do
      him = create(:user)
      task = create(:task, assigned_to: him.id)
      task.update_attributes(assigned_to: "")
      expect(task.errors).to be_empty
      expect(task.assigned_to).to eq(nil)
      expect(task.assignee).to eq(nil)
    end

    [nil, Time.now.utc_offset + 3600].each do |offset|
      before do
        adjust_timezone(offset)
      end

      it "should update due date based on selected bucket within #{offset ? 'different' : 'current'} timezone" do
        task = create(:task, due_at: Time.now.midnight.tomorrow, bucket: "due_tomorrow")
        task.update_attributes(bucket: "due_this_week")
        expect(task.errors).to be_empty
        expect(task.bucket).to eq("due_this_week")
        expect(task.due_at.change(usec: 0)).to eq(Time.zone.now.end_of_week.change(usec: 0))
      end

      it "should update due date if specific calendar date selected within #{offset ? 'different' : 'current'} timezone" do
        task = create(:task, due_at: Time.now.midnight.tomorrow, bucket: "due_tomorrow")
        task.update_attributes(bucket: "specific_time", calendar: "2020-03-20")
        expect(task.errors).to be_empty
        expect(task.bucket).to eq("specific_time")
        expect(task.due_at.to_i).to eq(Time.parse("2020-03-20").to_i)
      end
    end
  end

  describe "Task/Complete" do
    it "should complete a task that is overdue" do
      task = create(:task, due_at: 2.days.ago, bucket: "overdue")
      task.update_attributes(completed_at: Time.now, completed_by: task.user.id)

      expect(task.errors).to be_empty
      expect(task.completed_at).not_to eq(nil)
      expect(task.completor).to eq(task.user)
    end

    it "should complete a task due sometime in the future" do
      task = create(:task, due_at: Time.now.midnight.tomorrow, bucket: "due_tomorrow")
      task.update_attributes(completed_at: Time.now, completed_by: task.user.id)

      expect(task.errors).to be_empty
      expect(task.completed_at).not_to eq(nil)
      expect(task.completor).to eq(task.user)
    end

    it "should complete a task that is due on specific date in the future" do
      task = create(:task, calendar: "10/10/2022 12:00 AM", bucket: "specific_time")
      task.calendar = nil # Calendar is not saved in the database; we need it only to set the :due_at.
      task.update_attributes(completed_at: Time.now, completed_by: task.user.id)
      expect(task.errors).to be_empty
      expect(task.completed_at).not_to eq(nil)
      expect(task.completor).to eq(task.user)
    end

    it "should complete a task that is due on specific date in the past" do
      task = create(:task, calendar: "10/10/1992 12:00 AM", bucket: "specific_time")
      task.calendar = nil # Calendar is not saved in the database; we need it only to set the :due_at.
      task.update_attributes(completed_at: Time.now, completed_by: task.user.id)
      expect(task.errors).to be_empty
      expect(task.completed_at).not_to eq(nil)
      expect(task.completor).to eq(task.user)
    end

    it "completion should preserve original due date" do
      due_at = Time.now - 42.days
      task = create(:task, due_at: due_at, bucket: "specific_time",
                           calendar: due_at.strftime('%Y-%m-%d %H:%M'))
      task.update_attributes(completed_at: Time.now, completed_by: task.user.id, calendar: '')

      expect(task.completed?).to eq(true)
      expect(task.due_at).to eq(due_at.utc.strftime('%Y-%m-%d %H:%M'))
    end
  end

  # named_scope :my, lambda { |user| { :conditions => [ "(user_id = ? AND assigned_to IS NULL) OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  describe "task.my?" do
    let(:current_user) { create(:user) }

    it "should match a task created by the user" do
      task = create(:task, user: current_user, assignee: nil)
      expect(task.my?(current_user)).to eq(true)
    end

    it "should match a task assigned to the user" do
      task = create(:task, user: create(:user), assignee: current_user)
      expect(task.my?(current_user)).to eq(true)
    end

    it "should Not match a task not created by the user" do
      task = create(:task, user: create(:user))
      expect(task.my?(current_user)).to eq(false)
    end

    it "should Not match a task created by the user but assigned to somebody else" do
      task = create(:task, user: current_user, assignee: create(:user))
      expect(task.my?(current_user)).to eq(false)
    end
  end

  # named_scope :assigned_by, lambda { |user| { :conditions => [ "user_id = ? AND assigned_to IS NOT NULL AND assigned_to != ?", user.id, user.id ], :include => :assignee } }
  describe "task.assigned_by?" do
    let(:current_user) { create(:user) }

    it "should match a task assigned by the user to somebody else" do
      task = create(:task, user: current_user, assignee: create(:user))
      expect(task.assigned_by?(current_user)).to eq(true)
    end

    it "should Not match a task not created by the user" do
      task = create(:task, user: create(:user))
      expect(task.assigned_by?(current_user)).to eq(false)
    end

    it "should Not match a task not assigned to anybody" do
      task = create(:task, assignee: nil)
      expect(task.assigned_by?(current_user)).to eq(false)
    end

    it "should Not match a task assigned to the user" do
      task = create(:task, assignee: current_user)
      expect(task.assigned_by?(current_user)).to eq(false)
    end
  end

  # named_scope :tracked_by, lambda { |user| { :conditions => [ "user_id = ? OR assigned_to = ?", user.id, user.id ], :include => :assignee } }
  describe "task.tracked_by?" do
    let(:current_user) { create(:user) }

    it "should match a task created by the user" do
      task = create(:task, user: current_user)
      expect(task.tracked_by?(current_user)).to eq(true)
    end

    it "should match a task assigned to the user" do
      task = create(:task, assignee: current_user)
      expect(task.tracked_by?(current_user)).to eq(true)
    end

    it "should Not match a task that is neither created nor assigned to the user" do
      task = create(:task, user: create(:user), assignee: create(:user))
      expect(task.tracked_by?(current_user)).to eq(false)
    end
  end

  describe "task.computed_bucket" do
    context "when overdue" do
      subject { described_class.new(due_at: 1.days.ago, bucket: "specific_time") }

      it "returns a sensible value" do
        expect(subject.computed_bucket).to eq("overdue")
      end
    end

    context "when due today" do
      subject { described_class.new(due_at: Time.now, bucket: "specific_time") }

      it "returns a sensible value" do
        expect(subject.computed_bucket).to eq("due_today")
      end
    end

    context "when due tomorrow" do
      subject { described_class.new(due_at: 1.days.from_now.end_of_day, bucket: "specific_time") }

      it "returns a sensible value" do
        expect(subject.computed_bucket).to eq("due_tomorrow")
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
        Timecop.freeze(Time.local(2014, 1, 1, 16, 14)) do
          expect(subject.computed_bucket).to eq("due_next_week")
        end
      end
    end

    context "when due later" do
      subject { described_class.new(due_at: 1.month.from_now, bucket: "specific_time") }

      it "returns a sensible value" do
        expect(subject.computed_bucket).to eq("due_later")
      end
    end
  end

  describe "task.at_specific_time?" do
    context "when the due date is at the beginning of the day" do
      subject { described_class.new(due_at: Time.zone.now.beginning_of_day) }

      it "returns false" do
        expect(subject.at_specific_time?).to eq(false)
      end
    end

    context "when the due date is at the end of the day" do
      subject { described_class.new(due_at: Time.zone.now.end_of_day) }

      it "returns false" do
        expect(subject.at_specific_time?).to eq(false)
      end
    end

    context "when the due date is any other time" do
      subject { described_class.new(due_at: Time.zone.parse("2014-01-01 18:36:43")) }

      it "returns true" do
        expect(subject.at_specific_time?).to eq(true)
      end
    end
  end

  describe "Exportable" do
    describe "unassigned tasks" do
      let(:task1) { build(:task, user: create(:user), assignee: nil) }
      let(:task2) { build(:task, user: create(:user, first_name: nil, last_name: nil), assignee: nil) }
      it_should_behave_like("exportable") do
        let(:exported) { [task1, task2] }
      end
    end

    describe "assigned tasks" do
      let(:task1) { build(:task, user: create(:user), assignee: create(:user)) }
      let(:task2) { build(:task, user: create(:user, first_name: nil, last_name: nil), assignee: create(:user, first_name: nil, last_name: nil)) }
      it_should_behave_like("exportable") do
        let(:exported) { [task1, task2] }
      end
    end

    describe "completed tasks" do
      let(:task1) { build(:task, user: create(:user), completor: create(:user), completed_at: 1.day.ago) }
      let(:task2) { build(:task, user: create(:user, first_name: nil, last_name: nil), completor: create(:user, first_name: nil, last_name: nil), completed_at: 1.day.ago) }
      it_should_behave_like("exportable") do
        let(:exported) { [task1, task2] }
      end
    end
  end

  describe "#parse_calendar_date" do
    it "should parse the date" do
      @task = Task.new(calendar: '2020-12-23')
      expect(Time).to receive(:parse).with('2020-12-23')
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
        expect(Task.visible_on_dashboard(@user)).to include(@t1)
      end

      it "should show tasks which are assigned to the user" do
        expect(Task.visible_on_dashboard(@user)).to include(@t3, @t5)
      end

      it "should not show tasks which are not assigned to the user" do
        expect(Task.visible_on_dashboard(@user)).not_to include(@t4)
      end

      it "should not show tasks which are created by the user but assigned" do
        expect(Task.visible_on_dashboard(@user)).not_to include(@t2)
      end

      it "should not include completed tasks" do
        expect(Task.visible_on_dashboard(@user)).not_to include(@t6)
      end
    end

    context "by_due_at" do
      it "should show tasks ordered by due_at" do
        t1 = create(:task, name: 't1', bucket: "due_asap")
        t2 = create(:task, calendar: 5.days.from_now.strftime("%Y-%m-%d %H:%M"), bucket: "specific_time")
        t3 = create(:task, name: 't3', bucket: "due_next_week")
        t4 = create(:task, calendar: 20.days.from_now.strftime("%Y-%m-%d %H:%M"), bucket: "specific_time")
        expect(Task.by_due_at).to eq([t1, t2, t3, t4])
      end
    end
  end
end
