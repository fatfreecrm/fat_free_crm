# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
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
  it "should create a new instance given valid attributes" do
    Contact.create!(first_name: "Billy", last_name: "Bones")
  end

  describe "Update existing contact" do
    before(:each) do
      @contact = create(:contact, account: create(:account))
    end

    it "should create new account if requested so" do
      expect do
        @contact.update_with_account_and_permissions(
          account: { name: "New account" },
          contact: { first_name: "Billy" }
        )
      end.to change(Account, :count).by(1)
      expect(Account.last.name).to eq("New account")
      expect(@contact.first_name).to eq("Billy")
    end

    it "should change account if another account was selected" do
      @another_account = create(:account)
      expect do
        @contact.update_with_account_and_permissions(
          account: { id: @another_account.id },
          contact: { first_name: "Billy" }
        )
      end.not_to change(Account, :count)
      expect(@contact.account).to eq(@another_account)
      expect(@contact.first_name).to eq("Billy")
    end

    it "should drop existing Account if [create new account] is blank" do
      expect do
        @contact.update_with_account_and_permissions(
          account: { name: "" },
          contact: { first_name: "Billy" }
        )
      end.not_to change(Account, :count)
      expect(@contact.account).to eq(nil)
      expect(@contact.first_name).to eq("Billy")
    end

    it "should drop existing Account if [-- None --] is selected from list of accounts" do
      expect do
        @contact.update_with_account_and_permissions(
          account: { id: "" },
          contact: { first_name: "Billy" }
        )
      end.not_to change(Account, :count)
      expect(@contact.account).to eq(nil)
      expect(@contact.first_name).to eq("Billy")
    end

    it "should change account if entered name of another account was found" do
      @another_account = create(:account, name: "Another name")
      expect do
        @contact.update_with_account_and_permissions(
          account: { name: "Another name" },
          contact: { first_name: "Billy" }
        )
      end.not_to change(Account, :count)
      expect(@contact.account).to eq(@another_account)
      expect(@contact.first_name).to eq("Billy")
    end
  end

  describe "Attach" do
    before do
      @contact = create(:contact)
    end

    it "should return nil when attaching existing asset" do
      @task = create(:task, asset: @contact)
      @opportunity = create(:opportunity)
      @contact.opportunities << @opportunity

      expect(@contact.attach!(@task)).to eq(nil)
      expect(@contact.attach!(@opportunity)).to eq(nil)
    end

    it "should return non-empty list of attachments when attaching new asset" do
      @task = create(:task)
      @opportunity = create(:opportunity)

      expect(@contact.attach!(@task)).to eq([@task])
      expect(@contact.attach!(@opportunity)).to eq([@opportunity])
    end
  end

  describe "Discard" do
    before do
      @contact = create(:contact)
    end

    it "should discard a task" do
      @task = create(:task, asset: @contact)
      expect(@contact.tasks.count).to eq(1)

      @contact.discard!(@task)
      expect(@contact.reload.tasks).to eq([])
      expect(@contact.tasks.count).to eq(0)
    end

    it "should discard an opportunity" do
      @opportunity = create(:opportunity)
      @contact.opportunities << @opportunity
      expect(@contact.opportunities.count).to eq(1)

      @contact.discard!(@opportunity)
      expect(@contact.opportunities).to eq([])
      expect(@contact.opportunities.count).to eq(0)
    end
  end

  describe "Exportable" do
    describe "assigned contact" do
      let(:contact1) { build(:contact, assignee: create(:user)) }
      let(:contact2) { build(:contact, user: create(:user, first_name: nil, last_name: nil), assignee: create(:user, first_name: nil, last_name: nil)) }
      it_should_behave_like("exportable") do
        let(:exported) { [contact1, contact2] }
      end
    end

    describe "unassigned contact" do
      let(:contact1) { build(:contact, assignee: nil) }
      let(:contact2) { build(:contact, user: create(:user, first_name: nil, last_name: nil), assignee: nil) }
      it_should_behave_like("exportable") do
        let(:exported) { [contact1, contact2] }
      end
    end
  end

  describe "permissions" do
    it_should_behave_like Ability, Contact
  end

  describe "text_search" do
    before do
      @contact = create(:contact, first_name: "Bob", last_name: "Dillion", email: 'bob_dillion@example.com', phone: '+1 123 456 789')
    end

    it "should search first_name" do
      expect(Contact.text_search('Bob')).to eq([@contact])
    end

    it "should search last_name" do
      expect(Contact.text_search('Dillion')).to eq([@contact])
    end

    it "should search whole name" do
      expect(Contact.text_search('Bob Dillion')).to eq([@contact])
    end

    it "should search whole name reversed" do
      expect(Contact.text_search('Dillion Bob')).to eq([@contact])
    end

    it "should search email" do
      expect(Contact.text_search('example')).to eq([@contact])
    end

    it "should search phone" do
      expect(Contact.text_search('123')).to eq([@contact])
    end

    it "should not break with a single quote" do
      contact2 = create(:contact, first_name: "Shamus", last_name: "O'Connell", email: 'bob_dillion@example.com', phone: '+1 123 456 789')
      expect(Contact.text_search("O'Connell")).to eq([contact2])
    end

    it "should not break on special characters" do
      expect(Contact.text_search('@$%#^@!')).to eq([])
    end
  end
end
