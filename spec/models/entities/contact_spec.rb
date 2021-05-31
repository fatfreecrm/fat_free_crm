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
  let(:user) { create(:user) }

  it "should create a new instance given valid attributes" do
    Contact.create!(first_name: "Billy", last_name: "Bones", user: user)
  end

  it "must create a new instance for a given model" do
    lead = create(:lead)
    account = create(:account)
    opportunity = create(:opportunity)
    @contact = Contact.create_for(lead, account, opportunity, account: {})
    expect(@contact.valid?).to eq true
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

describe "field validations" do
  let(:new_record) do
    Contact.new(
      first_name: "ChristopherChristopherChristopherChristopherChristopherChristopherChristopher",
      last_name: "BonesBonesBonesBonesBonesBonesBonesBonesBonesBonesBonesBonesBonesBonesBonesBones",
      title: 'This is a really long title for the contact and it should thow an error.',
      department: 'This is a really long name for the department and it should thow an error.',
      email: 'bob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillion@example.com',
      alt_email: 'bob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillionbob_dillion@example.com',
      phone: '+1 123 456 7891 123 456 7891 123 456 7891 123 456 7891 123 456 789',
      mobile: '+1 123 456 7891 123 456 7891 123 456 7891 123 456 7891 123 456 789',
      fax: '+1 123 456 7891 123 456 7891 123 456 789 123 456 7891 123 456 789',
      blog: 'This is a test of how many characters before it throws an error message.This is a test of how many characters before it throws an error message.This is a test of how many characters before it throws an error message.',
      linkedin: 'This is my linkedin name and it is way to long. This is my linkedin name and it is way to long. This is my linkedin name and it is way to long.',
      twitter: 'This is my twitter name and it is way to long. This is my twitter name and it is way to long. This is my twitter name and it is way to long.',
      skype: 'This is my skype name and it is way to long. This is my skype name and it is way to long. This is my skype name and it is way to long.'
    )
  end

  it "validate first_name max_length 64" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:first_name]).to include("is too long (maximum is 64 characters)")
  end

  it "validate last_name max_length 64" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:last_name]).to include("is too long (maximum is 64 characters)")
  end

  it "validate title max_length 64" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:title]).to include("is too long (maximum is 64 characters)")
  end

  it "validate department max_length 254" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:department]).to include("is too long (maximum is 64 characters)")
  end

  it "validate email max_length 254" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:email]).to include("is too long (maximum is 254 characters)")
  end

  it "validate alt_email max_length 254" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:alt_email]).to include("is too long (maximum is 254 characters)")
  end

  it "validate phone max_length 32" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:phone]).to include("is too long (maximum is 32 characters)")
  end

  it "validate mobile max_length 32" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:mobile]).to include("is too long (maximum is 32 characters)")
  end

  it "validate fax max_length 32" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:fax]).to include("is too long (maximum is 32 characters)")
  end

  it "validate blog max_length 128" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:blog]).to include("is too long (maximum is 128 characters)")
  end

  it "validate linkedin max_length 128" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:linkedin]).to include("is too long (maximum is 128 characters)")
  end

  it "validate twitter max_length 128" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:twitter]).to include("is too long (maximum is 128 characters)")
  end

  it "validate skype max_length 128" do
    expect(new_record).to_not be_valid
    expect(new_record.errors.messages[:skype]).to include("is too long (maximum is 128 characters)")
  end
end
