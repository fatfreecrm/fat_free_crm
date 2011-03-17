# == Schema Information
# Schema version: 27
#
# Table name: opportunities
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  campaign_id     :integer(4)
#  assigned_to     :integer(4)
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Private")
#  source          :string(32)
#  stage           :string(32)
#  probability     :integer(4)
#  amount          :decimal(12, 2)
#  discount        :decimal(12, 2)
#  closes_on       :date
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Opportunity do

  before { login }

  it "should create a new instance given valid attributes" do
    @account = Factory(:account)
    Opportunity.create!(:name => "Opportunity", :account => @account)
  end

  it "should be possible to create opportunity with the same name" do
    first  = Factory(:opportunity, :name => "Hello", :user => @current_user)
    lambda { Factory(:opportunity, :name => "Hello", :user => @current_user) }.should_not raise_error(ActiveRecord::RecordInvalid)
  end

  describe "Update existing opportunity" do
    before(:each) do
      @account = Factory(:account)
      @opportunity = Factory(:opportunity, :account => @account)
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
      @another_account = Factory(:account)
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :id => @another_account.id },
        :opportunity => { :name => "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should == @another_account
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should not drop existing Account if [create new account] is blank" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :name => "" },
        :opportunity => { :name => "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should_not == nil
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end

    it "should not drop existing Account if [-- None --] is selected from list of accounts" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :id => "" },
        :opportunity => { :name => "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should_not == nil
      @opportunity.name.gsub(/#\d+ /,'').should == "Hello"
    end
  end

  describe "Named scopes" do
    it "should find non-closed opportunities" do
      @opportunities = [
        Factory(:opportunity, :stage => nil,        :amount => 1),
        Factory(:opportunity, :stage => "analysis", :amount => 1),
        Factory(:opportunity, :stage => "won",      :amount => 2),
        Factory(:opportunity, :stage => "won",      :amount => 2),
        Factory(:opportunity, :stage => "lost",     :amount => 3),
        Factory(:opportunity, :stage => "lost",     :amount => 3)
      ]
      Opportunity.pipeline.sum(:amount).should ==  2
      Opportunity.won.sum(:amount).should      ==  4
      Opportunity.lost.sum(:amount).should     ==  6
      Opportunity.sum(:amount).should          == 12
    end
  end

  describe "Attach" do
    before do
      @opportunity = Factory(:opportunity)
    end

    it "should return nil when attaching existing asset" do
      @task = Factory(:task, :asset => @opportunity, :user => @current_user)
      @contact = Factory(:contact)
      @opportunity.contacts << @contact

      @opportunity.attach!(@task).should == nil
      @opportunity.attach!(@contact).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = Factory(:task, :user => @current_user)
      @contact = Factory(:contact)

      @opportunity.attach!(@task).should == [ @task ]
      @opportunity.attach!(@contact).should == [ @contact ]
    end
  end

  describe "Discard" do
    before do
      @opportunity = Factory(:opportunity)
    end

    it "should discard a task" do
      @task = Factory(:task, :asset => @opportunity, :user => @current_user)
      @opportunity.tasks.count.should == 1

      @opportunity.discard!(@task)
      @opportunity.reload.tasks.should == []
      @opportunity.tasks.count.should == 0
    end

    it "should discard an contact" do
      @contact = Factory(:contact)
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
        Factory(:opportunity, :user => Factory(:user), :assignee => Factory(:user))
        Factory(:opportunity, :user => Factory(:user, :first_name => nil, :last_name => nil), :assignee => Factory(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Opportunity.all }
      end
    end

    describe "unassigned opportunity" do
      before do
        Account.delete_all
        Factory(:opportunity, :user => Factory(:user), :assignee => nil)
        Factory(:opportunity, :user => Factory(:user, :first_name => nil, :last_name => nil), :assignee => nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Opportunity.all }
      end
    end
  end
end
