# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: leads
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  campaign_id     :integer
#  assigned_to     :integer
#  first_name      :string(64)      default(""), not null
#  last_name       :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  title           :string(64)
#  company         :string(64)
#  source          :string(32)
#  status          :string(32)
#  referred_by     :string(64)
#  email           :string(64)
#  alt_email       :string(64)
#  phone           :string(32)
#  mobile          :string(32)
#  blog            :string(128)
#  linkedin        :string(128)
#  facebook        :string(128)
#  twitter         :string(128)
#  rating          :integer         default(0), not null
#  do_not_call     :boolean         default(FALSE), not null
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#  skype           :string(128)
#

require 'spec_helper'

describe Lead do

  let!(:current_user) { create :user }

  it "should create a new instance given valid attributes" do
    Lead.create!(first_name: "Billy", last_name: "Bones")
  end

  describe "Attach" do
    before do
      @lead = create(:lead)
    end

    it "should return nil when attaching existing task" do
      @task = create(:task, asset: @lead, user: current_user)
      @lead.attach!(@task).should == nil
    end

    it "should return non-empty list of tasks when attaching new task" do
      @task = create(:task, user: current_user)
      @lead.attach!(@task).should == [ @task ]
    end
  end

  describe "Discard" do
    before do
      @lead = create(:lead)
    end

    it "should discard a task" do
      @task = create(:task, asset: @lead, user: current_user)
      @lead.tasks.count.should == 1

      @lead.discard!(@task)
      @lead.reload.tasks.should == []
      @lead.tasks.count.should == 0
    end
  end

  describe "Exportable" do
    describe "assigned lead" do
      before do
        Lead.delete_all
        create(:lead, user: create(:user), assignee: create(:user))
        create(:lead, user: create(:user, first_name: nil, last_name: nil), assignee: create(:user, first_name: nil, last_name: nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Lead.all }
      end
    end

    describe "unassigned lead" do
      before do
        Lead.delete_all
        create(:lead, user: create(:user), assignee: nil)
        create(:lead, user: create(:user, first_name: nil, last_name: nil), assignee: nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Lead.all }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Lead
  end
end
