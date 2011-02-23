# == Schema Information
# Schema version: 27
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
#  username          :string(32)      default(""), not null
#  email             :string(64)      default(""), not null
#  first_name        :string(32)
#  last_name         :string(32)
#  title             :string(64)
#  company           :string(64)
#  alt_email         :string(64)
#  phone             :string(32)
#  mobile            :string(32)
#  aim               :string(32)
#  yahoo             :string(32)
#  google            :string(32)
#  skype             :string(32)
#  password_hash     :string(255)     default(""), not null
#  password_salt     :string(255)     default(""), not null
#  persistence_token :string(255)     default(""), not null
#  perishable_token  :string(255)     default(""), not null
#  last_request_at   :datetime
#  last_login_at     :datetime
#  current_login_at  :datetime
#  last_login_ip     :string(255)
#  current_login_ip  :string(255)
#  login_count       :integer(4)      default(0), not null
#  deleted_at        :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  admin             :boolean(1)      not null
#  suspended_at      :datetime
#
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @valid_attributes = {
      :username => "username",
      :email => "user@example.com"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end

  describe "should destroy the users unless she has no related assets" do
    before(:each) do
      @user = Factory(:user)
    end

    %w(account campaign lead contact opportunity).each do |asset|
      it "should not destroy the user if she owns #{asset}" do
        Factory(asset, :user => @user)
        @user.destroy
        lambda { @user.reload }.should_not raise_error(ActiveRecord::RecordNotFound)
        @user.deleted?.should == false
      end

      it "should not destroy the user if she has #{asset} assigned" do
        Factory(asset, :assignee => @user)
        @user.destroy
        lambda { @user.reload }.should_not raise_error(ActiveRecord::RecordNotFound)
        @user.deleted?.should == false
      end
    end

    it "should not destroy the user if she owns a comment" do
      login
      account = Factory(:account, :user => @current_user)
      Factory(:comment, :user => @user, :commentable => account)
      @user.destroy
      lambda { @user.reload }.should_not raise_error(ActiveRecord::RecordNotFound)
      @user.deleted?.should == false
    end

    it "should not destroy the current user" do
      login
      @current_user.destroy
      lambda { @current_user.reload }.should_not raise_error(ActiveRecord::RecordNotFound)
      @current_user.deleted?.should == false
    end

    it "should destroy the user" do
      @user.destroy
      lambda { @user.reload }.should raise_error(ActiveRecord::RecordNotFound)
      @user.deleted?.should == true
    end

    it "once the user gets deleted all her activity records must be deleted too" do
      login
      Factory(:activity, :user => @user, :subject => Factory(:account))
      Factory(:activity, :user => @user, :subject => Factory(:contact))
      @user.activities.count.should == 2
      @user.destroy
      @user.activities.count.should == 0
    end

    it "once the user gets deleted all her permissions must be deleted too" do
      Factory(:permission, :user => @user, :asset => Factory(:account))
      Factory(:permission, :user => @user, :asset => Factory(:contact))
      @user.permissions.count.should == 2
      @user.destroy
      @user.permissions.count.should == 0
    end

    it "once the user gets deleted all her preferences must be deleted too" do
      Factory(:preference, :user => @user, :name => "Hello", :value => "World")
      Factory(:preference, :user => @user, :name => "World", :value => "Hello")
      @user.preferences.count.should == 2
      @user.destroy
      @user.preferences.count.should == 0
    end
  end

  it "should set suspended timestamp upon creation if signups need approval and the user is not an admin" do
    Setting.stub(:user_signup).and_return(:needs_approval)
    @user = Factory(:user, :suspended_at => nil)
    @user.suspended?.should == true
  end

  it "should not set suspended timestamp upon creation if signups need approval and the user is an admin" do
    Setting.stub(:user_signup).and_return(:needs_approval)
    @user = Factory(:user, :admin => true, :suspended_at => nil)
    @user.suspended?.should == false
  end

  describe "LDAP integration" do
    describe "update_or_create_from_ldap" do
      describe "when a matching user exists" do
        before :each do
          @user = Factory.create(:user, :username => 'test.user')
          LDAPAccess.stub!(:get_user_details).with('test.user').and_return( mock_ldap_user_details() )
        end

        it "should return the user" do
          User.update_or_create_from_ldap('test.user').should == @user
        end

        it "should update the user's details from ldap" do
          u = User.update_or_create_from_ldap('test.user')
          u.username.should == 'test.user'
          u.first_name.should == 'Test'
          u.last_name.should == 'User'
          u.email.should == 'test.user@example.com'
          u.phone.should == '+44 2071834250'
          u.mobile.should == '+44 7890123456'
        end

        it "should just return the user if they aren't found in ldap" do
          LDAPAccess.stub!(:get_user_details).with('test.user').and_return( nil )
          User.update_or_create_from_ldap('test.user').should == @user
        end
      end

      describe "when no matching user exists" do
        it "should get the users details from ldap" do
          LDAPAccess.should_receive(:get_user_details).with('test.user').and_return( nil )
          User.update_or_create_from_ldap('test.user')
        end

        it "should return nil if user not found in ldap" do
          LDAPAccess.stub!(:get_user_details).with('test.user').and_return( nil )
          User.update_or_create_from_ldap('test.user').should be_nil
        end

        it "should create a user with the details from ldap" do
          Factory.create(:user)
          LDAPAccess.stub!(:get_user_details).with('test.user').and_return( mock_ldap_user_details() )
          u = nil
          lambda do
            u = User.update_or_create_from_ldap('test.user')
          end.should change(User, :count).by(1)
          u.should_not be_nil
          u.should_not be_new_record
          u.username.should == 'test.user'
          u.first_name.should == 'Test'
          u.last_name.should == 'User'
          u.email.should == 'test.user@example.com'
          u.phone.should == '+44 2071834250'
          u.mobile.should == '+44 7890123456'
          u.admin.should == false
        end

        it "should create the user as an admin if they are the first user" do
          LDAPAccess.stub!(:get_user_details).with('test.user').and_return( mock_ldap_user_details() )
          u = nil
          lambda do
            u = User.update_or_create_from_ldap('test.user')
          end.should change(User, :count).by(1)
          u.should_not be_nil
          u.should_not be_new_record
          u.admin.should == true
        end
      end
    end

    describe "valid_ldap_credentials" do
      before :each do
        @user = Factory.create(:user, :username => 'test.user')
      end

      it "should call LdapAccess.authenticate with the username and password" do
        LDAPAccess.should_receive(:authenticate).with('test.user', 'secret')
        @user.send(:valid_ldap_credentials?, 'secret')
      end

      it "should return true if the authenticate call is successful" do
        LDAPAccess.stub!(:authenticate).and_return(true)
        @user.send(:valid_ldap_credentials?, 'secret').should be_true
      end

      it "should return false if the authenticate call fails" do
        LDAPAccess.stub!(:authenticate).and_return(false)
        @user.send(:valid_ldap_credentials?, 'secret').should be_false
      end
    end

    def mock_ldap_user_details(options = {})
      {
        :mail => 'test.user@example.com',
        :objectclass => 'organizationalPerson',
        :uid => 'test.user',
        :telephonenumber => '+44 2071834250',
        :mobile => '+44 7890123456',
        :cn => 'Test User',
        :userpassword => "{SHA}1hjGSLBIHmbdLGniQAzrOhSQu7w=",
        :sn => 'User',
        :dn => 'uid=test.user,dc=example,dc=com',
        :displayname => 'Test User',
        :givenname => 'Test'
      }.merge(options)
    end
  end
end
