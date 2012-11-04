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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Lead do

  before { login }

  it "should create a new instance given valid attributes" do
    Lead.create!(:first_name => "Billy", :last_name => "Bones")
  end

  describe "Attach" do
    before do
      @lead = FactoryGirl.create(:lead)
    end

    it "should return nil when attaching existing task" do
      @task = FactoryGirl.create(:task, :asset => @lead, :user => current_user)

      @lead.attach!(@task).should == nil
    end

    it "should return non-empty list of tasks when attaching new task" do
      @task = FactoryGirl.create(:task, :user => current_user)

      @lead.attach!(@task).should == [ @task ]
    end
  end

  describe "Discard" do
    before do
      @lead = FactoryGirl.create(:lead)
    end

    it "should discard a task" do
      @task = FactoryGirl.create(:task, :asset => @lead, :user => current_user)
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
        FactoryGirl.create(:lead, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
        FactoryGirl.create(:lead, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => FactoryGirl.create(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Lead.all }
      end
    end

    describe "unassigned lead" do
      before do
        Lead.delete_all
        FactoryGirl.create(:lead, :user => FactoryGirl.create(:user), :assignee => nil)
        FactoryGirl.create(:lead, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => nil)
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
