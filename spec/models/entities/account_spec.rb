# frozen_string_literal: true

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
  it "should create a new instance given valid attributes" do
    Account.create!(name: "Test Account")
  end

  describe "Creating or selecting" do
    it "must create a new account" do
      @account = Account.create_or_select_for(nil, name: "Account T")

      expect(Account.count).to eq(1)
      expect(Account.first).to eq(@account)
    end

    it "must select an existing account based on id" do
      @account = create(:account)

      expect(Account.create_or_select_for(nil, id: @account.id)).to eq(@account)
    end

    it "must select an existing account based on name" do
      @account = create(:account)

      expect(Account.create_or_select_for(nil, name: @account.name)).to eq(@account)
    end

    it "must create a new account based on existing model" do
      @contact = create(:contact)
      @account = Account.create_or_select_for(@contact, name: "Account T")
      expect(@account.user).to eq(@contact.user)
    end
  end

  describe "Attach" do
    before do
      @account = create(:account)
    end

    it "should return nil when attaching existing asset" do
      @task = create(:task, asset: @account)
      @contact = create(:contact)
      @account.contacts << @contact
      @opportunity = create(:opportunity)
      @account.opportunities << @opportunity

      expect(@account.attach!(@task)).to eq(nil)
      expect(@account.attach!(@contact)).to eq(nil)
      expect(@account.attach!(@opportunity)).to eq(nil)
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = create(:task)
      @contact = create(:contact)
      @opportunity = create(:opportunity)

      expect(@account.attach!(@task)).to eq([@task])
      expect(@account.attach!(@contact)).to eq([@contact])
      expect(@account.attach!(@opportunity)).to eq([@opportunity])
    end
  end

  describe "Discard" do
    before do
      @account = create(:account)
    end

    it "should discard a task" do
      @task = create(:task, asset: @account)
      expect(@account.tasks.count).to eq(1)

      @account.discard!(@task)
      expect(@account.reload.tasks).to eq([])
      expect(@account.tasks.count).to eq(0)
    end

    it "should discard a contact" do
      @contact = create(:contact)
      @account.contacts << @contact
      expect(@account.contacts.count).to eq(1)

      @account.discard!(@contact)
      expect(@account.contacts).to eq([])
      expect(@account.contacts.count).to eq(0)
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
      let(:account1) { build(:account, assignee: create(:user)) }
      let(:account2) { build(:account, user: create(:user, first_name: nil, last_name: nil), assignee: create(:user, first_name: nil, last_name: nil)) }
      it_should_behave_like("exportable") do
        let(:exported) { [account1, account2] }
      end
    end

    describe "unassigned account" do
      let(:account1) { build(:account, assignee: nil) }
      let(:account2) { build(:account, user: create(:user, first_name: nil, last_name: nil), assignee: nil) }
      it_should_behave_like("exportable") do
        let(:exported) { [account1, account2] }
      end
    end
  end

  describe "Before save" do
    it "create new: should replace empty category string with nil" do
      account = build(:account, category: '')
      account.save
      expect(account.category).to eq(nil)
    end

    it "update existing: should replace empty category string with nil" do
      account = create(:account, category: '')
      account.save
      expect(account.category).to eq(nil)
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Account
  end

  describe "scopes" do
    context "visible_on_dashboard" do
      before do
        @another_user = create(:user)
        @user = create(:user)
        @a1 = create(:account, user: @user)
        @a2 = create(:account, user: @user, assignee: @another_user)
        @a3 = create(:account, assignee: @user)
        @a4 = create(:account, assignee: @another_user)
        @a5 = create(:account, assignee: @user)
      end

      it "should show accounts which have been created by the user and are unassigned" do
        expect(Account.visible_on_dashboard(@user)).to include(@a1)
      end

      it "should show accounts which are assigned to the user" do
        expect(Account.visible_on_dashboard(@user)).to include(@a3, @a5)
      end

      it "should not show accounts which are not assigned to the user" do
        expect(Account.visible_on_dashboard(@user)).not_to include(@a4)
      end

      it "should not show accounts which are created by the user but assigned" do
        expect(Account.visible_on_dashboard(@user)).not_to include(@a2)
      end
    end

    context "by_name" do
      it "should show accounts ordered by name" do
        @a1 = create(:account, name: "Account A")
        @a2 = create(:account, name: "Account Z")
        @a3 = create(:account, name: "Account J")
        @a4 = create(:account, name: "Account X")
        @a5 = create(:account, name: "Account L")

        expect(Account.by_name).to eq([@a1, @a3, @a5, @a4, @a2])
      end
    end
  end
end
