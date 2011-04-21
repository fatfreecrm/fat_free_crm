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

  before(:each) do
    login
  end

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

  describe "tags" do
    before do
      @lead = Factory(:lead)
    end

    it "has no tags by default" do
      @lead.tags.should be_empty
    end

    it "can have tags assigned" do
      @lead.tag_list = "foo, bar, example"
      @lead.save
      tags = @lead.tag_list
      tags.size.should == 3
      tags.should include('foo', 'bar', 'example')
    end

    describe 'adding' do
      it "handles appending 0 tags" do
        @lead.add_tag("")
        @lead.tag_list.should be_empty
      end

      it "handles appending nil" do
        @lead.add_tag(nil)
        @lead.tag_list.should be_empty
      end

      it "can add 1 tag" do
        @lead.add_tag("moo")
        @lead.tag_list.should == %w(moo)
      end

      it "can add more than 1 tag" do
        @lead.add_tag("moo, foo, bar")
        @lead.tag_list.should == %w(moo foo bar)
      end
    end

    describe 'deleting' do
      it 'handles deleting nil' do
        @lead.delete_tag(nil)
        @lead.tag_list.should be_empty
      end

      it 'handles deleting an unexisting tag' do
        @lead.add_tag('foo')
        @lead.delete_tag('moo')
        @lead.tag_list.should == ['foo']
      end


      it 'handles deleting an existing tag' do
        @lead.add_tag('foo')
        @lead.delete_tag('foo')
        @lead.tag_list.should be_empty
      end
    end
  end

  describe "search_and_filter" do
    before(:each) do
      @user = Factory(:user)
    end

    it "returns nothing when no leads" do
      Lead.search_and_filter(:user => @user).should be_empty
    end

    it "returns the leads of the user" do
      lead1 = Factory(:lead, :user => @user, :access => 'private')
      lead2 = Factory(:lead, :user => @user, :access => 'private')
      Factory(:lead, :access => 'private')

      leads = Lead.search_and_filter(:user => @user)
      leads.size.should == 2
      leads.should include(lead1, lead2)
    end

    it "returns the leads of the user with given statuses" do
      lead1 = Factory(:lead, :user => @user, :access => 'private', :status => 'new')
      lead2 = Factory(:lead, :user => @user, :access => 'private', :status => 'new')
      lead3 = Factory(:lead, :user => @user, :access => 'private', :status => 'contacted')
      lead4 = Factory(:lead, :user => @user, :access => 'private', :status => 'converted')

      leads = Lead.search_and_filter(:user => @user, :filter => "new,contacted")
      leads.size.should == 3
      leads.should include(lead1)
      leads.should include(lead2)
      leads.should include(lead3)
    end

    it "returns the leads matching the query" do
      lead1 = Factory(:lead, :access => 'private', :user => @user, :first_name => 'house')
      lead2 = Factory(:lead, :access => 'private', :user => @user, :last_name => 'house')
      lead3 = Factory(:lead, :access => 'private', :user => @user, :company => 'house')
      lead4 = Factory(:lead, :access => 'private', :user => @user)

      leads = Lead.search_and_filter(:user => @user, :query => 'house')
      leads.size.should == 3
      leads.should include(lead1)
      leads.should include(lead2)
      leads.should include(lead3)
    end

    it "returns the leads filtered by tags" do
      lead1 = Factory(:lead, :user => @user, :tag_list => "moo")
      lead2 = Factory(:lead, :user => @user, :tag_list => "moo, foo")
      lead3 = Factory(:lead, :user => @user, :tag_list => "moo, bar")
      lead4 = Factory(:lead, :user => @user)

      leads = Lead.search_and_filter(:user => @user, :tags => "foo, moo")
      leads.size.should == 1
      leads.should include(lead2)
    end

    it "returns leads sorted by default field if user doesn't have a preference" do
      lead1 = Factory(:lead, :user => @user, :first_name => "zone", :created_at => 3.days.ago)
      lead2 = Factory(:lead, :user => @user, :first_name => "alan", :created_at => 2.days.ago)
      lead3 = Factory(:lead, :user => @user, :first_name => "albert", :created_at => 1.day.ago)

      leads = Lead.search_and_filter(:user => @user)
      leads.should == [lead3, lead2, lead1]
    end

    it "returns leads sorted by the user preference" do
      Factory(:preference, :user => @user, :name => 'leads_sort_by', :value => Base64.encode64(Marshal.dump("leads.first_name ASC")))

      lead1 = Factory(:lead, :user => @user, :first_name => "zone", :created_at => 3.days.ago)
      lead2 = Factory(:lead, :user => @user, :first_name => "alan", :created_at => 2.days.ago)
      lead3 = Factory(:lead, :user => @user, :first_name => "albert", :created_at => 1.day.ago)

      leads = Lead.search_and_filter(:user => @user)
      leads.should == [lead2, lead3, lead1]
    end

    it "can combine different search and filter options" do
      lead1 = Factory(:lead, :user => @user, :first_name => "alan", :tag_list => "investigate", :status => "contacted")
      lead2 = Factory(:lead, :first_name => "alan", :tag_list => "investigate", :status => "contacted")
      lead3 = Factory(:lead, :user => @user, :tag_list => "investigate")

      leads = Lead.search_and_filter(:user => @user)
      leads.should == [lead1]
    end
  end
end
