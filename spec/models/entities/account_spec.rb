# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: accounts
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  assigned_to     :integer
#  name            :string(64)      default(""), not null
#  access          :string(8)       default("Public")
#  website         :string(64)
#  toll_free_phone :string(32)
#  phone           :string(32)
#  fax             :string(32)
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  email           :string(64)
#  background_info :string(255)
#  rating          :integer         default(0), not null
#  category        :string(32)
#  image_url       :string(100)
#

require 'spec_helper'

describe Account do

  before { login }

  it "should create a new instance given valid attributes" do
    Account.create!(:name => "Test Account", :user => FactoryGirl.create(:user))
  end

  describe "Attach" do
    before do
      @account = FactoryGirl.create(:account)
    end

    it "should return nil when attaching existing asset" do
      @task = FactoryGirl.create(:task, :asset => @account, :user => current_user)
      @contact = FactoryGirl.create(:contact)
      @account.contacts << @contact
      @opportunity = FactoryGirl.create(:opportunity)
      @account.opportunities << @opportunity

      @account.attach!(@task).should == nil
      @account.attach!(@contact).should == nil
      @account.attach!(@opportunity).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = FactoryGirl.create(:task, :user => current_user)
      @contact = FactoryGirl.create(:contact)
      @opportunity = FactoryGirl.create(:opportunity)

      @account.attach!(@task).should == [ @task ]
      @account.attach!(@contact).should == [ @contact ]
      @account.attach!(@opportunity).should == [ @opportunity ]
    end
  end

  describe "Discard" do
    before do
      @account = FactoryGirl.create(:account)
    end

    it "should discard a task" do
      @task = FactoryGirl.create(:task, :asset => @account, :user => current_user)
      @account.tasks.count.should == 1

      @account.discard!(@task)
      @account.reload.tasks.should == []
      @account.tasks.count.should == 0
    end

    it "should discard a contact" do
      @contact = FactoryGirl.create(:contact)
      @account.contacts << @contact
      @account.contacts.count.should == 1

      @account.discard!(@contact)
      @account.contacts.should == []
      @account.contacts.count.should == 0
    end

# Commented out this test. "super from singleton method that is defined to multiple classes is not supported;"
# ------------------------------------------------------
#    it "should discard an opportunity" do
#      @opportunity = FactoryGirl.create(:opportunity)
#      @account.opportunities << @opportunity
#      @account.opportunities.count.should == 1

#      @account.discard!(@opportunity)
#      @account.opportunities.should == []
#      @account.opportunities.count.should == 0
#    end
  end

  describe "Exportable" do
    describe "assigned account" do
      before do
        Account.delete_all
        FactoryGirl.create(:account, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
        FactoryGirl.create(:account, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => FactoryGirl.create(:user, :first_name => nil, :last_name => nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Account.all }
      end
    end

    describe "unassigned account" do
      before do
        Account.delete_all
        FactoryGirl.create(:account, :user => FactoryGirl.create(:user), :assignee => nil)
        FactoryGirl.create(:account, :user => FactoryGirl.create(:user, :first_name => nil, :last_name => nil), :assignee => nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Account.all }
      end
    end
  end

  describe "Before save" do
    describe "category" do
      it "create new: should replace empty category string with nil" do
        account = FactoryGirl.build(:account, :category => '')
        account.save
        account.category.should == nil
      end

      it "update existing: should replace empty category string with nil" do
        account = FactoryGirl.create(:account, :category => '')
        account.save
        account.category.should == nil
      end
    end

    describe "image_url" do
      it "create new: should create account when image_url has a value" do
        account = FactoryGirl.create(:account, :image_url => 'http://www.markdaniels.com.au/image/logo.png')
        account.save
        account.image_url.should == 'http://www.markdaniels.com.au/image/logo.png'
      end

      it "create new: should create account when image_url is nil" do
        account = FactoryGirl.create(:account, :image_url => nil)
        account.save
        account.image_url.should == nil
      end

      it "create new: should add http and create account when image_url does not have scheme" do
        account = FactoryGirl.create(:account, :image_url => 'www.markdaniels.com.au/image/logo.png')
        account.save
        account.image_url.should == 'http://www.markdaniels.com.au/image/logo.png'
      end

      it "create new: should error when image_url has a valid server but invalid resource (image)" do
        lambda {
          account = FactoryGirl.create(:account, :image_url => 'www.markdaniels.com.au/image/logo1234.png')
          account.save
        }.should raise_error(Exception){ |ex|
          ex.message.should == 'Validation failed: Unable to get response from image url.'
        }
      end

      it "create new: should error as not a valid url (invalid scheme)" do
        lambda {
          account = FactoryGirl.create(:account, :image_url => 'fred:\\www.markdaniels.com.au/image/logo1234.png')
          account.save
        }.should raise_error(Exception){ |ex|
          ex.message.should == 'Validation failed: image is not a valid url (bad URI(is not URI?): fred:\\www.markdaniels.com.au/image/logo1234.png).'
        }
      end

      it 'Test URL being greater than 100' do
        pending("Need a valid url greater than 100 or the check against the url removed")
      end

      it 'Test URL with https' do
        pending("A valid https url (can this be done as would need security etc)")
      end

      it "update: should update account when image_url is null and is updated to a value" do
        account = FactoryGirl.create(:account, :image_url => nil)
        account.save
        account.image_url.should == nil
        account.image_url = 'http://www.markdaniels.com.au/image/logo.png'
        account.save
        account.image_url.should == 'http://www.markdaniels.com.au/image/logo.png'
      end

      it "update: should update account when image_url has a value and is updated to nil" do
        account = FactoryGirl.create(:account, :image_url => 'http://www.markdaniels.com.au/image/logo.png')
        account.save
        account.image_url.should == 'http://www.markdaniels.com.au/image/logo.png'
        account.image_url = nil
        account.save
        account.image_url.should == nil
      end

      it "update: should error when updated image_url has a valid server but invalid resource (image)" do
        account = FactoryGirl.create(:account, :image_url => 'http://www.markdaniels.com.au/image/logo.png')
        account.save
        account.image_url.should == 'http://www.markdaniels.com.au/image/logo.png'
        lambda {
          account.image_url = 'www.markdaniels.com.au/image/logo1234.png'
          account.save
        }.should raise_error(Exception){ |ex|
          ex.message.should == 'Validation failed: Unable to get response from image url.'
        }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Account
  end

  describe "scopes" do
    context "visible_on_dashboard" do
      before :each do
        @user = FactoryGirl.create(:user)
        @a1 = FactoryGirl.create(:account, :user => @user)
        @a2 = FactoryGirl.create(:account, :user => @user, :assignee => FactoryGirl.create(:user))
        @a3 = FactoryGirl.create(:account, :user => FactoryGirl.create(:user), :assignee => @user)
        @a4 = FactoryGirl.create(:account, :user => FactoryGirl.create(:user), :assignee => FactoryGirl.create(:user))
        @a5 = FactoryGirl.create(:account, :user => FactoryGirl.create(:user), :assignee => @user)
      end

      it "should show accounts which have been created by the user and are unassigned" do
        Account.visible_on_dashboard(@user).should include(@a1)
      end

      it "should show accounts which are assigned to the user" do
        Account.visible_on_dashboard(@user).should include(@a3, @a5)
      end

      it "should not show accounts which are not assigned to the user" do
        Account.visible_on_dashboard(@user).should_not include(@a4)
      end

      it "should not show accounts which are created by the user but assigned" do
        Account.visible_on_dashboard(@user).should_not include(@a2)
      end
    end

    context "by_name" do
      it "should show accounts ordered by name" do
        @a1 = FactoryGirl.create(:account, :name => "Account A")
        @a2 = FactoryGirl.create(:account, :name => "Account Z")
        @a3 = FactoryGirl.create(:account, :name => "Account J")
        @a4 = FactoryGirl.create(:account, :name => "Account X")
        @a5 = FactoryGirl.create(:account, :name => "Account L")

        Account.by_name.should == [@a1, @a3, @a5, @a4, @a2]
      end
    end
  end
end
