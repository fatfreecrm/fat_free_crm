# == Schema Information
# Schema version: 21
#
# Table name: users
#
#  id                :integer(4)      not null, primary key
#  uuid              :string(36)
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
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @valid_attributes = {
      :username => "username",
      :password => "password",
      :password_confirmation => "password",
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
  end

end
