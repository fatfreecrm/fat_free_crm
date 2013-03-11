# == Schema Information
#
# Table name: campaigns
#
#  id                  :integer         not null, primary key
#  user_id             :integer
#  assigned_to         :integer
#  name                :string(64)      default(""), not null
#  access              :string(8)       default("Public")
#  status              :string(64)
#  budget              :decimal(12, 2)
#  target_leads        :integer
#  target_conversion   :float
#  target_revenue      :decimal(12, 2)
#  leads_count         :integer
#  opportunities_count :integer
#  revenue             :decimal(12, 2)
#  starts_on           :date
#  ends_on             :date
#  objectives          :text
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  background_info     :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Campaign do

  let(:current_user) { FactoryGirl.create(:user) }

  it "should create a new instance given valid attributes" do
    Campaign.create!(:name => "Campaign", :user => FactoryGirl.create(:user))
  end

  describe "Attach" do
    before do
      @campaign = FactoryGirl.create(:campaign)
    end

    it "should return nil when attaching existing asset" do
      @task = FactoryGirl.create(:task, :asset => @campaign, :user => current_user)
      @lead = FactoryGirl.create(:lead, :campaign => @campaign)
      @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaign)

      @campaign.attach!(@task).should == nil
      @campaign.attach!(@lead).should == nil
      @campaign.attach!(@opportunity).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = FactoryGirl.create(:task, :user => current_user)
      @lead = FactoryGirl.create(:lead)
      @opportunity = FactoryGirl.create(:opportunity)

      @campaign.attach!(@task).should == [ @task ]
      @campaign.attach!(@lead).should == [ @lead ]
      @campaign.attach!(@opportunity).should == [ @opportunity ]
    end

    it "should increment leads count when attaching a new lead" do
      @leads_count = @campaign.leads_count
      @lead = FactoryGirl.create(:lead)

      @campaign.attach!(@lead)
      @campaign.reload.leads_count.should == @leads_count + 1
    end

    it "should increment opportunities count when attaching new opportunity" do
      @opportunities_count = @campaign.opportunities_count
      @opportunity = FactoryGirl.create(:opportunity)
      @campaign.attach!(@opportunity)
      @campaign.reload.opportunities_count.should == @opportunities_count + 1
    end
  end

  describe "Detach" do
    before do
      @campaign = FactoryGirl.create(:campaign, :leads_count => 42, :opportunities_count => 42)
    end

    it "should discard a task" do
      @task = FactoryGirl.create(:task, :asset => @campaign, :user => current_user)
      @campaign.tasks.count.should == 1

      @campaign.discard!(@task)
      @campaign.reload.tasks.should == []
      @campaign.tasks.count.should == 0
    end

    it "should discard a lead" do
      @lead = FactoryGirl.create(:lead, :campaign => @campaign)
      @campaign.reload.leads_count.should == 43

      @campaign.discard!(@lead)
      @campaign.leads.should == []
      @campaign.reload.leads_count.should == 42
    end

    it "should discard an opportunity" do
      @opportunity = FactoryGirl.create(:opportunity, :campaign => @campaign)
      @campaign.reload.opportunities_count.should == 43

      @campaign.discard!(@opportunity)
      @campaign.opportunities.should == []
      @campaign.reload.opportunities_count.should == 42
    end
  end

  describe "Exportable" do
    describe "assigned campaign" do
      before do
        Campaign.delete_all
        FactoryGirl.create(:campaign, :user => FactoryGirl.create(:user, :first_name => "John", :last_name => "Smith"), :assignee => FactoryGirl.create(:user))
        FactoryGirl.create(:campaign, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => FactoryGirl.create(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Campaign.all }
      end
    end

    describe "unassigned campaign" do
      before do
        Campaign.delete_all
        FactoryGirl.create(:campaign, :user => FactoryGirl.create(:user), :assignee => nil)
        FactoryGirl.create(:campaign, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Campaign.all }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Campaign
  end
end
