# == Schema Information
# Schema version: 27
#
# Table name: contacts
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  lead_id         :integer(4)
#  assigned_to     :integer(4)
#  reports_to      :integer(4)
#  first_name      :string(64)      default(""), not null
#  last_name       :string(64)      default(""), not null
#  access          :string(8)       default("Private")
#  title           :string(64)
#  department      :string(64)
#  source          :string(32)
#  email           :string(64)
#  alt_email       :string(64)
#  phone           :string(32)
#  mobile          :string(32)
#  fax             :string(32)
#  blog            :string(128)
#  linkedin        :string(128)
#  facebook        :string(128)
#  twitter         :string(128)
#  born_on         :date
#  do_not_call     :boolean(1)      not null
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Contact do
  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Contact.create!(:first_name => "Billy", :last_name => "Bones")
  end

  describe "Update existing contact" do
    before(:each) do
      @account = Factory(:account)
      @contact = Factory(:contact, :account => @account)
    end

    it "should create new account if requested so" do
      lambda { @contact.update_with_account_and_permissions({
        :account => { :name => "New account" },
        :contact => { :first_name => "Billy" }
      })}.should change(Account, :count).by(1)
      Account.last.name.should == "New account"
      @contact.first_name.should == "Billy"
    end

    it "should update the account another account was selected" do
      @another_account = Factory(:account)
      lambda { @contact.update_with_account_and_permissions({
        :account => { :id => @another_account.id },
        :contact => { :first_name => "Billy" }
      })}.should_not change(Account, :count)
      @contact.account.should == @another_account
      @contact.first_name.should == "Billy"
    end

    it "should drop existing Account if [create new account] is blank" do
      lambda { @contact.update_with_account_and_permissions({
        :account => { :name => "" },
        :contact => { :first_name => "Billy" }
      })}.should_not change(Account, :count)
      @contact.account.should == nil
      @contact.first_name.should == "Billy"
    end

    it "should drop existing Account if [-- None --] is selected from list of accounts" do
      lambda { @contact.update_with_account_and_permissions({
        :account => { :id => "" },
        :contact => { :first_name => "Billy" }
      })}.should_not change(Account, :count)
      @contact.account.should == nil
      @contact.first_name.should == "Billy"
    end
  end

  describe "Attach" do
    before do
      @contact = Factory(:contact)
    end

    it "should return nil when attaching existing asset" do
      @task = Factory(:task, :asset => @contact, :user => @current_user)
      @opportunity = Factory(:opportunity)
      @contact.opportunities << @opportunity

      @contact.attach!(@task).should == nil
      @contact.attach!(@opportunity).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = Factory(:task, :user => @current_user)
      @opportunity = Factory(:opportunity)

      @contact.attach!(@task).should == [ @task ]
      @contact.attach!(@opportunity).should == [ @opportunity ]
    end
  end

  describe "Discard" do
    before do
      @contact = Factory(:contact)
    end

    it "should discard a task" do
      @task = Factory(:task, :asset => @contact, :user => @current_user)
      @contact.tasks.count.should == 1

      @contact.discard!(@task)
      @contact.reload.tasks.should == []
      @contact.tasks.count.should == 0
    end

    it "should discard an opportunity" do
      @opportunity = Factory(:opportunity)
      @contact.opportunities << @opportunity
      @contact.opportunities.count.should == 1

      @contact.discard!(@opportunity)
      @contact.opportunities.should == []
      @contact.opportunities.count.should == 0
    end
  end

  describe "tags" do
    before do
      @contact = Factory(:contact)
    end

    it "has no tags by default" do
      @contact.tags.should be_empty
    end

    it "can have tags assigned" do
      @contact.tag_list = "foo, bar, example"
      @contact.save
      tags = @contact.tag_list
      tags.size.should == 3
      tags.should include('foo', 'bar', 'example')
    end

    describe 'adding' do
      it "handles appending 0 tags" do
        @contact.add_tag("")
        @contact.tag_list.should be_empty
      end

      it "handles appending nil" do
        @contact.add_tag(nil)
        @contact.tag_list.should be_empty
      end

      it "can add 1 tag" do
        @contact.add_tag("moo")
        @contact.tag_list.should == %w(moo)
      end

      it "can add more than 1 tag" do
        @contact.add_tag("moo, foo, bar")
        @contact.tag_list.should == %w(moo foo bar)
      end
    end

    describe 'deleting' do
      it 'handles deleting nil' do
        @contact.delete_tag(nil)
        @contact.tag_list.should be_empty
      end

      it 'handles deleting an unexisting tag' do
        @contact.add_tag('foo')
        @contact.delete_tag('moo')
        @contact.tag_list.should == ['foo']
      end


      it 'handles deleting an existing tag' do
        @contact.add_tag('foo')
        @contact.delete_tag('foo')
        @contact.tag_list.should be_empty
      end
    end
  end

  describe "search_and_filter" do
    before(:each) do
      @user = Factory(:user)
    end

    it "returns nothing when no contacts" do
      Contact.search_and_filter(:user => @user).should be_empty
    end

    it "returns the contacts of the user" do
      contact1 = Factory(:contact, :user => @user, :access => 'private')
      contact2 = Factory(:contact, :user => @user, :access => 'private')
      Factory(:contact, :access => 'private')

      contacts = Contact.search_and_filter(:user => @user)
      contacts.size.should == 2
      contacts.should include(contact1, contact2)
    end

    it "ignores any filter param because Contact doesn't have an :only scope" do
      contact1 = Factory(:contact, :user => @user, :access => 'private', :first_name => 'house')
      contact2 = Factory(:contact, :user => @user, :access => 'private', :last_name => 'house')
      contact3 = Factory(:contact, :user => @user, :access => 'private', :email => 'house@example.com')
      contact4 = Factory(:contact, :access => 'private')

      contacts = Contact.search_and_filter(:user => @user, :filter => 'house')
      contacts.size.should == 3
      contacts.should include(contact1, contact2, contact3)
    end

    it "returns the contacts matching the query" do
      contact1 = Factory(:contact, :access => 'private', :user => @user, :first_name => 'house')
      contact2 = Factory(:contact, :access => 'private', :user => @user, :email => 'house@example.com')
      contact3 = Factory(:contact, :access => 'private', :user => @user)

      contacts = Contact.search_and_filter(:user => @user, :query => 'house')
      contacts.size.should == 2
      contacts.should include(contact1, contact2)
    end

    it "returns the user's contacts filtered by tags" do
      contact1 = Factory(:contact, :user => @user, :tag_list => "moo")
      contact2 = Factory(:contact, :user => @user, :tag_list => "moo, foo")
      contact3 = Factory(:contact, :user => @user, :tag_list => "moo, bar")
      contact4 = Factory(:contact, :user => @user)
      contact5 = Factory(:contact, :tag_list => 'foo, moo, bar', :access => 'private')

      contacts = Contact.search_and_filter(:user => @user, :tags => "foo, moo")
      contacts.should == [contact2]
    end

    it "returns contacts sorted by default field if user doesn't have a preference" do
      contact1 = Factory(:contact, :user => @user, :first_name => "mike", :last_name => "zone")
      contact2 = Factory(:contact, :user => @user, :first_name => "dave", :last_name => "alan")
      contact3 = Factory(:contact, :user => @user, :first_name => "derek", :last_name => "albert")

      contacts = Contact.search_and_filter(:user => @user)
      contacts.should == [contact2, contact3, contact1]
    end

    it "returns contacts sorted by the user preference" do
      Factory(:preference, :user => @user, :name => 'contacts_sort_by', :value => Base64.encode64(Marshal.dump("contacts.first_name DESC")))

      contact1 = Factory(:contact, :user => @user, :first_name => "mike", :last_name => "zone", :created_at => 3.days.ago)
      contact2 = Factory(:contact, :user => @user, :first_name => "dave", :last_name => "alan", :created_at => 2.days.ago)
      contact3 = Factory(:contact, :user => @user, :first_name => "derek", :last_name => "albert", :created_at => 1.day.ago)

      contacts = Contact.search_and_filter(:user => @user)
      contacts.should == [contact1, contact3, contact2]
    end

    it "can combine different search and filter options" do
      # mine
      # query, tagged
      contact1 = Factory(:contact, :first_name => 'house', :user => @user, :tag_list => "investigate")
      # query
      contact2 = Factory(:contact, :user => @user, :last_name => 'house', :tag_list => 'boring')
      # tagged
      contact3 = Factory(:contact, :user => @user, :tag_list => 'investigate')

      # public
      # query, tagged
      contact4 = Factory(:contact, :first_name => 'house', :tag_list => 'investigate')
      # query
      contact5 = Factory(:contact, :last_name => 'house', :tag_list => 'boring')
      # tagged
      contact6 = Factory(:contact, :tag_list => 'investigate')

      # private
      # query, tagged
      contact7 = Factory(:contact, :access => 'private', :first_name => 'house', :tag_list => "investigate")
      # query
      contact8 = Factory(:contact, :access => 'private', :last_name => 'house', :tag_list => 'boring')
      # tagged
      contact9 = Factory(:contact, :access => 'private', :tag_list => 'investigate')

      # get all my and all public leads tagged 'investigate' in the state 'contacted' with 'house' somewhere in the text
      contacts = Contact.search_and_filter(:user => @user, :tags => 'investigate', :query => 'house')
      contacts.size.should == 2
      contacts.should include(contact1, contact4)
    end
  end
end
