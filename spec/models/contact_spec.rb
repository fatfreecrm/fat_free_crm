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

  before { login }

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

  describe "Exportable" do
    describe "assigned contact" do
      before do
        Contact.delete_all
        Factory(:contact, :user => Factory(:user), :assignee => Factory(:user))
        Factory(:contact, :user => Factory(:user, :first_name => nil, :last_name => nil), :assignee => Factory(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Contact.all }
      end
    end

    describe "unassigned contact" do
      before do
        Account.delete_all
        Factory(:contact, :user => Factory(:user), :assignee => nil)
        Factory(:contact, :user => Factory(:user, :first_name => nil, :last_name => nil), :assignee => nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Contact.all }
      end
    end
  end
end
