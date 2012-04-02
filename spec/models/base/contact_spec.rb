# == Schema Information
#
# Table name: contacts
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  lead_id         :integer
#  assigned_to     :integer
#  reports_to      :integer
#  first_name      :string(64)      default(""), not null
#  last_name       :string(64)      default(""), not null
#  access          :string(8)       default("Public")
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
#  do_not_call     :boolean         default(FALSE), not null
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  background_info :string(255)
#  skype           :string(128)
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Contact do

  before { login }

  it "should create a new instance given valid attributes" do
    Contact.create!(:first_name => "Billy", :last_name => "Bones")
  end

  describe "Update existing contact" do
    before(:each) do
      @account = FactoryGirl.create(:account)
      @contact = FactoryGirl.create(:contact, :account => @account)
    end

    it "should create new account if requested so" do
      lambda { @contact.update_with_account_and_permissions({
        :account => { :name => "New account" },
        :contact => { :first_name => "Billy" }
      })}.should change(Account, :count).by(1)
      Account.last.name.should == "New account"
      @contact.first_name.should == "Billy"
    end

    it "should change account if another account was selected" do
      @another_account = FactoryGirl.create(:account)
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
      @contact = FactoryGirl.create(:contact)
    end

    it "should return nil when attaching existing asset" do
      @task = FactoryGirl.create(:task, :asset => @contact, :user => @current_user)
      @opportunity = FactoryGirl.create(:opportunity)
      @contact.opportunities << @opportunity

      @contact.attach!(@task).should == nil
      @contact.attach!(@opportunity).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = FactoryGirl.create(:task, :user => @current_user)
      @opportunity = FactoryGirl.create(:opportunity)

      @contact.attach!(@task).should == [ @task ]
      @contact.attach!(@opportunity).should == [ @opportunity ]
    end
  end

  describe "Discard" do
    before do
      @contact = FactoryGirl.create(:contact)
    end

    it "should discard a task" do
      @task = FactoryGirl.create(:task, :asset => @contact, :user => @current_user)
      @contact.tasks.count.should == 1

      @contact.discard!(@task)
      @contact.reload.tasks.should == []
      @contact.tasks.count.should == 0
    end

    it "should discard an opportunity" do
      @opportunity = FactoryGirl.create(:opportunity)
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
        FactoryGirl.create(:contact, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
        FactoryGirl.create(:contact, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => FactoryGirl.create(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Contact.all }
      end
    end

    describe "unassigned contact" do
      before do
        Contact.delete_all
        FactoryGirl.create(:contact, :user => FactoryGirl.create(:user), :assignee => nil)
        FactoryGirl.create(:contact, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Contact.all }
      end
    end
  end
end

