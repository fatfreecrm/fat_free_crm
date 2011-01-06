# == Schema Information
# Schema version: 27
#
# Table name: leads
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  campaign_id     :integer(4)
#  assigned_to     :integer(4)
#  first_name      :string(64)      default(""), not null
#  last_name       :string(64)      default(""), not null
#  access          :string(8)       default("Private")
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
#  rating          :integer(4)      default(0), not null
#  do_not_call     :boolean(1)      not null
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lead do

  before { login }

  it "should create a new instance given valid attributes" do
    Lead.create!(:first_name => "Billy", :last_name => "Bones")
  end

  describe "Attach" do
    before do
      @lead = Factory(:lead)
    end

    it "should return nil when attaching existing task" do
      @task = Factory(:task, :asset => @lead, :user => @current_user)

      @lead.attach!(@task).should == nil
    end

    it "should return non-empty list of tasks when attaching new task" do
      @task = Factory(:task, :user => @current_user)

      @lead.attach!(@task).should == [ @task ]
    end
  end

  describe "Discard" do
    before do
      @lead = Factory(:lead)
    end

    it "should discard a task" do
      @task = Factory(:task, :asset => @lead, :user => @current_user)
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
        Factory(:lead, :user => Factory(:user), :assignee => Factory(:user))
        Factory(:lead, :user => Factory(:user, :first_name => nil, :last_name => nil), :assignee => Factory(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Lead.all }
      end
    end

    describe "unassigned lead" do
      before do
        Account.delete_all
        Factory(:lead, :user => Factory(:user), :assignee => nil)
        Factory(:lead, :user => Factory(:user, :first_name => nil, :last_name => nil), :assignee => nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Lead.all }
      end
    end
  end
end
