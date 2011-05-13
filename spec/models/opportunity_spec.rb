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

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Opportunity.create!(:name => "Opportunity")
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
      @opportunity.name.should == "Hello"
    end

    it "should update the account another account was selected" do
      @another_account = Factory(:account)
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :id => @another_account.id },
        :opportunity => { :name => "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should == @another_account
      @opportunity.name.should == "Hello"
    end

    it "should drop existing Account if [create new account] is blank" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :name => "" },
        :opportunity => { :name => "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should == nil
      @opportunity.name.should == "Hello"
    end

    it "should drop existing Account if [-- None --] is selected from list of accounts" do
      lambda { @opportunity.update_with_account_and_permissions({
        :account => { :id => "" },
        :opportunity => { :name => "Hello" }
      })}.should_not change(Account, :count)
      @opportunity.account.should == nil
      @opportunity.name.should == "Hello"
    end
  end

  describe "Named scopes" do
    it "should find non-closed opportunities" do
      @opportunities = [
        Factory(:opportunity, :stage => "analysis", :amount => 1),
        Factory(:opportunity, :stage => "won",      :amount => 2),
        Factory(:opportunity, :stage => "lost",     :amount => 7)
      ]
      Opportunity.sum(:amount).should == 10
      Opportunity.not_lost.sum(:amount).should == 3
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

  describe "tags" do
    before do
      @opportunity = Factory(:opportunity)
    end

    it "has no tags by default" do
      @opportunity.tags.should be_empty
    end

    it "can have tags assigned" do
      @opportunity.tag_list = "foo, bar, example"
      @opportunity.save
      tags = @opportunity.tag_list
      tags.size.should == 3
      tags.should include('foo', 'bar', 'example')
    end

    describe 'adding' do
      it "handles appending 0 tags" do
        @opportunity.add_tag("")
        @opportunity.tag_list.should be_empty
      end

      it "handles appending nil" do
        @opportunity.add_tag(nil)
        @opportunity.tag_list.should be_empty
      end

      it "can add 1 tag" do
        @opportunity.add_tag("moo")
        @opportunity.tag_list.should == %w(moo)
      end

      it "can add more than 1 tag" do
        @opportunity.add_tag("moo, foo, bar")
        @opportunity.tag_list.should == %w(moo foo bar)
      end
    end

    describe 'deleting' do
      it 'handles deleting nil' do
        @opportunity.delete_tag(nil)
        @opportunity.tag_list.should be_empty
      end

      it 'handles deleting an unexisting tag' do
        @opportunity.add_tag('foo')
        @opportunity.delete_tag('moo')
        @opportunity.tag_list.should == ['foo']
      end


      it 'handles deleting an existing tag' do
        @opportunity.add_tag('foo')
        @opportunity.delete_tag('foo')
        @opportunity.tag_list.should be_empty
      end
    end
  end

  describe "search_and_filter" do
    before(:each) do
      @user = Factory(:user)
    end

    it "returns nothing when no leads" do
      Opportunity.search_and_filter(:user => @user).should be_empty
    end

    it "returns the leads of the user" do
      opportunity1 = Factory(:opportunity, :user => @user, :access => 'private')
      opportunity2 = Factory(:opportunity, :user => @user, :access => 'private')
      Factory(:opportunity, :access => 'private')

      leads = Opportunity.search_and_filter(:user => @user)
      leads.size.should == 2
      leads.should include(opportunity1, opportunity2)
    end

    it "returns the leads of the user with given statuses" do
      opportunity1 = Factory(:opportunity, :user => @user, :access => 'private', :stage => 'new')
      opportunity2 = Factory(:opportunity, :user => @user, :access => 'private', :stage => 'new')
      opportunity3 = Factory(:opportunity, :user => @user, :access => 'private', :stage => 'contacted')
      opportunity4 = Factory(:opportunity, :user => @user, :access => 'private', :stage => 'converted')

      leads = Opportunity.search_and_filter(:user => @user, :filter => "new,contacted")
      leads.size.should == 3
      leads.should include(opportunity1)
      leads.should include(opportunity2)
      leads.should include(opportunity3)
    end

    it "returns the leads matching the query" do
      opportunity1 = Factory(:opportunity, :access => 'private', :user => @user, :name => 'house')
      opportunity2 = Factory(:opportunity, :access => 'private', :user => @user, :name => 'house')
      opportunity3 = Factory(:opportunity, :access => 'private', :user => @user, :name => 'house')
      opportunity4 = Factory(:opportunity, :access => 'private', :user => @user)

      leads = Opportunity.search_and_filter(:user => @user, :query => 'house')
      leads.size.should == 3
      leads.should include(opportunity1)
      leads.should include(opportunity2)
      leads.should include(opportunity3)
    end

    it "returns the user's leads filtered by tags" do
      opportunity1 = Factory(:opportunity, :user => @user, :tag_list => "moo")
      opportunity2 = Factory(:opportunity, :user => @user, :tag_list => "moo, foo")
      opportunity3 = Factory(:opportunity, :user => @user, :tag_list => "moo, bar")
      opportunity4 = Factory(:opportunity, :user => @user)
      opportunity5 = Factory(:opportunity, :tag_list => 'foo, moo, bar', :access => 'private')

      leads = Opportunity.search_and_filter(:user => @user, :tags => "foo, moo")
      leads.should == [opportunity2]
    end

    it "returns leads sorted by default field if user doesn't have a preference" do
      opportunity1 = Factory(:opportunity, :user => @user, :name => "zone", :created_at => 3.days.ago)
      opportunity2 = Factory(:opportunity, :user => @user, :name => "alan", :created_at => 2.days.ago)
      opportunity3 = Factory(:opportunity, :user => @user, :name => "albert", :created_at => 1.day.ago)

      leads = Opportunity.search_and_filter(:user => @user)
      leads.should == [opportunity3, opportunity2, opportunity1]
    end

    it "returns leads sorted by the user preference" do
      Factory(:preference, :user => @user, :name => 'opportunities_sort_by', :value => Base64.encode64(Marshal.dump("opportunities.name ASC")))

      opportunity1 = Factory(:opportunity, :user => @user, :name => "zone", :created_at => 3.days.ago)
      opportunity2 = Factory(:opportunity, :user => @user, :name => "alan", :created_at => 2.days.ago)
      opportunity3 = Factory(:opportunity, :user => @user, :name => "albert", :created_at => 1.day.ago)

      leads = Opportunity.search_and_filter(:user => @user)
      leads.should == [opportunity2, opportunity3, opportunity1]
    end

    it "can combine different search and filter options" do
      # mine
      # query, tagged, filtered
      opportunity1 = Factory(:opportunity, :name => 'house', :user => @user, :tag_list => "investigate", :stage => "contacted")
      # query, tagged
      opportunity2 = Factory(:opportunity, :name => 'house', :user => @user, :tag_list => "investigate", :stage => 'ignored')
      # query, filtered
      opportunity3 = Factory(:opportunity, :user => @user, :name => 'house', :tag_list => 'boring', :stage => 'contacted')
      # tagged, filtered
      opportunity4 = Factory(:opportunity, :user => @user, :tag_list => 'investigate', :stage => 'contacted')

      # public
      # query, tagged, filtered
      opportunity5 = Factory(:opportunity, :name => 'house', :tag_list => "investigate", :stage => "contacted")
      # query, tagged
      opportunity6 = Factory(:opportunity, :name => 'house', :tag_list => "investigate", :stage => 'ignored')
      # query, filtered
      opportunity7 = Factory(:opportunity, :name => 'house', :tag_list => 'boring', :stage => 'contacted')
      # tagged, filtered
      opportunity8 = Factory(:opportunity, :tag_list => 'investigate', :stage => 'contacted')

      # private
      # query, tagged, filtered
      opportunity9 = Factory(:opportunity, :access => 'private', :name => 'house', :tag_list => "investigate", :stage => "contacted")
      # query, tagged
      opportunity10 = Factory(:opportunity, :access => 'private', :name => 'house', :tag_list => "investigate", :stage => 'ignored')
      # query, filtered
      opportunity11 = Factory(:opportunity, :access => 'private', :name => 'house', :tag_list => 'boring', :stage => 'contacted')
      # tagged, filtered
      opportunity12 = Factory(:opportunity, :access => 'private', :tag_list => 'investigate', :stage => 'contacted')

      # get all my and all public leads tagged 'investigate' in the state 'contacted' with 'house' somewhere in the text
      leads = Opportunity.search_and_filter(:user => @user, :tags => 'investigate', :query => 'house', :filter => 'contacted')
      leads.should == [opportunity1, opportunity5]
    end
  end
  
  describe "named_scopes" do
    context "assigned_to" do
      before :each do
        @user = Factory(:user)
      end
      context "a user object is given as input" do
        it "should return opportunities which are assigned to a given user" do
          opportunity = Factory(:opportunity, :assigned_to => @user.id)
          Opportunity.assigned_to(@user).should == [opportunity]
        end
        it "should not return opportunities which are not assigned to a given user" do
          Factory(:opportunity, :assigned_to => Factory(:user))
          Opportunity.assigned_to(@user).should == []
        end
        it "should order by 'closes_on ASC'" do
          opportunity1 = Factory(:opportunity, :closes_on => 2.days.from_now, :assigned_to => @user.id)
          opportunity2 = Factory(:opportunity, :closes_on => 1.day.from_now, :assigned_to => @user.id)
          Opportunity.assigned_to(@user).should == [opportunity2, opportunity1]
        end
      end
      context "a user with options is given as input(a hash)" do
        it "should return opportunities which are assigned to a given user" do
          opportunity = Factory(:opportunity, :assigned_to => @user.id)
          Opportunity.assigned_to({:user => @user}).should == [opportunity]
        end
        it "should not return opportunities which are not assigned to a given user" do
          Factory(:opportunity, :assigned_to => Factory(:user))
          Opportunity.assigned_to({:user => @user}).should == []
        end
        it "should order by 'name ASC'" do
          opportunity1 = Factory(:opportunity, :name => "eat your lunch", :assigned_to => @user.id)
          opportunity2 = Factory(:opportunity, :name => "zebra racing", :assigned_to => @user.id)
          Opportunity.assigned_to({:user => @user, :order => "name ASC"}).should == [opportunity1, opportunity2]
        end
        it "should have a limit of 2" do
          Factory(:opportunity, :name => "eat your lunch", :assigned_to => @user.id)
          Factory(:opportunity, :name => "zebra racing", :assigned_to => @user.id)
          Factory(:opportunity, :name => "dog walking", :assigned_to => @user.id)
          Opportunity.assigned_to({:user => @user, :limit => 2}).count.should == 2
        end
      end
    end
  end
end
