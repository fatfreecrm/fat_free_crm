# == Schema Information
#
# Table name: opportunities
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  campaign_id     :integer
#  assigned_to     :integer
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  source          :string(32)
#  stage           :string(32)
#  probability     :integer
#  amount          :decimal(12, 2)
#  discount        :decimal(12, 2)
#  closes_on       :date
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Opportunity do

  before { login }

  it "should create a new instance given valid attributes" do
    @account = FactoryGirl.create(:account)
    Opportunity.create!(:name => "Opportunity", :account => @account)
  end

  it "should be possible to create opportunity with the same name" do
    first  = FactoryGirl.create(:opportunity, :name => "Hello", :user => @current_user)
    lambda { FactoryGirl.create(:opportunity, :name => "Hello", :user => @current_user) }.should_not raise_error(ActiveRecord::RecordInvalid)
  end

  describe "Update existing opportunity" do
    before(:each) do
      @account = FactoryGirl.create(:account)
      @opportunity = FactoryGirl.create(:opportunity, :account => @account)
    end

    it "should create new account if requested so" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :name => "New account" },
        :opportunity => { :name => "Hello" }
      })}.should change(Account, :count).by(1)
      Account.last.name.should == "New account"
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should update the account another account was selected" do
      @another_account = FactoryGirl.create(:account)
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :id => @another_account.id },
        :opportunity => { :name => "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should == @another_account
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should drop existing Account if [create new account] is blank" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :name => "" },
        :opportunity => { :name => "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should be_nil
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should drop existing Account if [-- None --] is selected from list of accounts" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :id => "" },
        :opportunity => { :name => "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should be_nil
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should set the probability to 0% if opportunity has been lost" do
      opportunity = FactoryGirl.create(:opportunity, :stage => "prospecting", :probability => 25)
      opportunity.update_attributes(:stage => 'lost')
      opportunity.reload
      opportunity.probability.should == 0
    end

    it "should set the probablility to 100% if opportunity has been won" do
      opportunity = FactoryGirl.create(:opportunity, :stage => "prospecting", :probability => 65)
      opportunity.update_attributes(:stage => 'won')
      opportunity.reload
      opportunity.probability.should == 100
    end
  end

  describe "Named scopes" do
    it "should find non-closed opportunities" do
      Opportunity.delete_all
      @opportunities = [
        FactoryGirl.create(:opportunity, :stage => nil,        :amount => 1),
        FactoryGirl.create(:opportunity, :stage => "analysis", :amount => 1),
        FactoryGirl.create(:opportunity, :stage => "won",      :amount => 2),
        FactoryGirl.create(:opportunity, :stage => "won",      :amount => 2),
        FactoryGirl.create(:opportunity, :stage => "lost",     :amount => 3),
        FactoryGirl.create(:opportunity, :stage => "lost",     :amount => 3)
      ]
      Opportunity.pipeline.sum(:amount).should ==  2
      Opportunity.won.sum(:amount).should      ==  4
      Opportunity.lost.sum(:amount).should     ==  6
      Opportunity.sum(:amount).should          == 12
    end
  end

  describe "Attach" do
    before do
      @opportunity = FactoryGirl.create(:opportunity)
    end

    it "should return nil when attaching existing asset" do
      @task = FactoryGirl.create(:task, :asset => @opportunity, :user => @current_user)
      @contact = FactoryGirl.create(:contact)
      @opportunity.contacts << @contact

      @opportunity.attach!(@task).should == nil
      @opportunity.attach!(@contact).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = FactoryGirl.create(:task, :user => @current_user)
      @contact = FactoryGirl.create(:contact)

      @opportunity.attach!(@task).should == [ @task ]
      @opportunity.attach!(@contact).should == [ @contact ]
    end
  end

  describe "Discard" do
    before do
      @opportunity = FactoryGirl.create(:opportunity)
    end

    it "should discard a task" do
      @task = FactoryGirl.create(:task, :asset => @opportunity, :user => @current_user)
      @opportunity.tasks.count.should == 1

      @opportunity.discard!(@task)
      @opportunity.reload.tasks.should == []
      @opportunity.tasks.count.should == 0
    end

    it "should discard an contact" do
      @contact = FactoryGirl.create(:contact)
      @opportunity.contacts << @contact
      @opportunity.contacts.count.should == 1

      @opportunity.discard!(@contact)
      @opportunity.contacts.should == []
      @opportunity.contacts.count.should == 0
    end
  end

  describe "Exportable" do
    describe "assigned opportunity" do
      before do
        Opportunity.delete_all
        FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
        FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => FactoryGirl.create(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Opportunity.all }
      end
    end

    describe "unassigned opportunity" do
      before do
        Opportunity.delete_all
        FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user), :assignee => nil)
        FactoryGirl.create(:opportunity, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Opportunity.all }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Opportunity
  end
end

