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
#

require 'spec_helper'

describe Account do

  let!(:current_user) { create :user }

  it "should create a new instance given valid attributes" do
    Account.create!(name: "Test Account", user: create(:user))
  end

  describe "Attach" do
    before do
      @account = create(:account)
    end

    it "should return nil when attaching existing asset" do
      @task = create(:task, asset: @account, user: current_user)
      @contact = create(:contact)
      @account.contacts << @contact
      @opportunity = create(:opportunity)
      @account.opportunities << @opportunity

      @account.attach!(@task).should == nil
      @account.attach!(@contact).should == nil
      @account.attach!(@opportunity).should == nil
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = create(:task, user: current_user)
      @contact = create(:contact)
      @opportunity = create(:opportunity)

      @account.attach!(@task).should == [ @task ]
      @account.attach!(@contact).should == [ @contact ]
      @account.attach!(@opportunity).should == [ @opportunity ]
    end
  end

  describe "Discard" do
    before do
      @account = create(:account)
    end

    it "should discard a task" do
      @task = create(:task, asset: @account, user: current_user)
      @account.tasks.count.should == 1

      @account.discard!(@task)
      @account.reload.tasks.should == []
      @account.tasks.count.should == 0
    end

    it "should discard a contact" do
      @contact = create(:contact)
      @account.contacts << @contact
      @account.contacts.count.should == 1

      @account.discard!(@contact)
      @account.contacts.should == []
      @account.contacts.count.should == 0
    end

# Commented out this test. "super from singleton method that is defined to multiple classes is not supported;"
# ------------------------------------------------------
#    it "should discard an opportunity" do
#      @opportunity = create(:opportunity)
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
        create(:account, user: create(:user), assignee: create(:user))
        create(:account, user: create(:user, first_name: nil, last_name: nil), assignee: create(:user, first_name: nil, last_name: nil))
      end
      it_should_behave_like("exportable") do
        let(:exported) { Account.all }
      end
    end

    describe "unassigned account" do
      before do
        Account.delete_all
        create(:account, user: create(:user), assignee: nil)
        create(:account, user: create(:user, first_name: nil, last_name: nil), assignee: nil)
      end
      it_should_behave_like("exportable") do
        let(:exported) { Account.all }
      end
    end
  end

  describe "Before save" do
    it "create new: should replace empty category string with nil" do
      account = build(:account, category: '')
      account.save
      account.category.should == nil
    end

    it "update existing: should replace empty category string with nil" do
      account = create(:account, category: '')
      account.save
      account.category.should == nil
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Account
  end

  describe "scopes" do
    context "visible_on_dashboard" do
      before :each do
        @user = create(:user)
        @a1 = create(:account, user: @user)
        @a2 = create(:account, user: @user, assignee: create(:user))
        @a3 = create(:account, user: create(:user), assignee: @user)
        @a4 = create(:account, user: create(:user), assignee: create(:user))
        @a5 = create(:account, user: create(:user), assignee: @user)
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
        @a1 = create(:account, name: "Account A")
        @a2 = create(:account, name: "Account Z")
        @a3 = create(:account, name: "Account J")
        @a4 = create(:account, name: "Account X")
        @a5 = create(:account, name: "Account L")

        Account.by_name.should == [@a1, @a3, @a5, @a4, @a2]
      end
    end
  end
end
