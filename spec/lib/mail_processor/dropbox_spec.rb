# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.dirname(__FILE__) + '/sample_emails/dropbox'

require "fat_free_crm/mail_processor/dropbox"

describe FatFreeCRM::MailProcessor::Dropbox do
  include MockIMAP

  before(:each) do
    @mock_address = "dropbox@example.com"
    @crawler = FatFreeCRM::MailProcessor::Dropbox.new
  end

  #------------------------------------------------------------------------------
  describe "Running the crawler" do
    before(:each) do
      mock_connect
      mock_disconnect
      mock_message(DROPBOX_EMAILS[:plain])
    end

    it "should discard a message if it's invalid" do
      expect(@crawler).to receive(:is_valid?).once.and_return(false)
      create(:user, email: "aaron@example.com")
      expect(@crawler).not_to receive(:archive)
      expect(@crawler).to receive(:discard).once
      @crawler.run
    end

    it "should discard a message if it can't find the user" do
      expect(@crawler).to receive(:is_valid?).once.and_return(true)
      expect(@crawler).not_to receive(:archive)
      expect(@crawler).to receive(:discard).once
      @crawler.run
    end

    it "should process a message if it finds the user" do
      create(:user, email: "aaron@example.com")
      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:discard)
      @crawler.run
    end
  end

  #------------------------------------------------------------------------------
  describe "Pipeline: processing keywords on the first line" do
    before(:each) do
      mock_connect
      mock_disconnect
      create(:user, email: "aaron@example.com")
    end

    it "should find the named asset and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line])
      @campaign = create(:campaign, name: "Got milk!?")
      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:with_recipients)
      @crawler.run

      expect(@campaign.emails.size).to eq(1)
      expect(@campaign.emails.first.mediator).to eq(@campaign)
    end

    it "should create the named asset and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line])
      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:with_recipients)
      @crawler.run

      @campaign = Campaign.find_by(name: 'Got milk')
      expect(@campaign).to be_instance_of(Campaign)
      expect(@campaign.emails.size).to eq(1)
      expect(@campaign.emails.first.mediator).to eq(@campaign)
    end

    it "should find the lead and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line_lead])
      @lead = create(:lead, first_name: "Cindy", last_name: "Cluster")
      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:with_recipients)
      @crawler.run

      expect(@lead.emails.size).to eq(1)
      expect(@lead.emails.first.mediator).to eq(@lead)
    end

    it "should create the lead and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line_lead])
      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:with_recipients)
      @crawler.run

      @lead = Lead.find_by(first_name: 'Cindy', last_name: 'Cluster')
      expect(@lead).to be_instance_of(Lead)
      expect(@lead.status).to eq("contacted")
      expect(@lead.emails.size).to eq(1)
      expect(@lead.emails.first.mediator).to eq(@lead)
    end

    it "should find the contact and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line_contact])
      @contact = create(:contact, first_name: "Cindy", last_name: "Cluster")
      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:with_recipients)
      @crawler.run

      expect(@contact.emails.size).to eq(1)
      expect(@contact.emails.first.mediator).to eq(@contact)
    end

    it "should create the contact and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line_contact])
      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:with_recipients)
      @crawler.run

      @contact = Contact.find_by(first_name: 'Cindy', last_name: 'Cluster')
      expect(@contact).to be_instance_of(Contact)
      expect(@contact.emails.size).to eq(1)
      expect(@contact.emails.first.mediator).to eq(@contact)
    end

    it "should move on if first line has no keyword" do
      mock_message(DROPBOX_EMAILS[:plain])
      expect(@crawler).to receive(:with_recipients).twice
      expect(@crawler).to receive(:with_forwarded_recipient).twice
      @crawler.run
    end
  end

  #------------------------------------------------------------------------------
  describe "Pipeline: processing recipients (To: recipient, Bcc: dropbox)" do
    before(:each) do
      mock_connect
      mock_disconnect
      mock_message(DROPBOX_EMAILS[:plain])
      create(:user, email: "aaron@example.com")
    end

    it "should find the asset and attach the email message" do
      @lead = create(:lead, email: "ben@example.com", access: "Public")
      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:with_forwarded_recipient)
      @crawler.run

      expect(@lead.emails.size).to eq(1)
      expect(@lead.emails.first.mediator).to eq(@lead)
    end

    it "should create the asset and attach the email message" do
      expect(@crawler).to receive(:archive).once
      expect { @crawler.run }.to change(Contact, :count).by(1)

      @contact = Contact.last
      expect(@contact.emails.size).to eq(1)
      expect(@contact.emails.first.mediator).to eq(@contact)
    end
  end

  #------------------------------------------------------------------------------
  describe "Pipeline: processing forwarded recipient (To: dropbox)" do
    before(:each) do
      mock_connect
      mock_disconnect
      create(:user, email: "aaron@example.com")
      mock_message(DROPBOX_EMAILS[:forwarded])
    end

    it "should find the asset and attach the email message" do
      @lead = create(:lead, email: "ben@example.com", access: "Public")
      expect(@crawler).to receive(:archive).once
      @crawler.run

      expect(@lead.emails.size).to eq(1)
      expect(@lead.emails.first.mediator).to eq(@lead)
    end

    it "should touch the asset" do
      now = Time.zone.now
      timezone = ActiveRecord::Base.default_timezone
      begin
        ActiveRecord::Base.default_timezone = :utc
        @lead = create(:lead, email: "ben@example.com", access: "Public", updated_at: 5.day.ago)

        @crawler.run
        expect(@lead.reload.updated_at.to_i).to be >= now.to_i
      ensure
        ActiveRecord::Base.default_timezone = timezone
      end
    end

    it "should change lead's status (:new => :contacted)" do
      @lead = create(:lead, email: "ben@example.com", access: "Public", status: "new")

      @crawler.run
      expect(@lead.reload.status).to eq("contacted")
    end

    it "should move on if forwarded recipient did not match" do
      expect(@crawler).to receive(:with_forwarded_recipient).twice
      @crawler.run
    end
  end

  #------------------------------------------------------------------------------
  describe "Pipeline: processing forwarded recipient from email sent to dropbox alias address" do
    before(:each) do
      @mock_address = "dropbox-alias-address@example.com"
      mock_connect
      mock_disconnect

      @settings = @crawler.instance_variable_get("@settings")
      @settings[:address_aliases] = ["dropbox@example.com"]

      create(:user, email: "aaron@example.com")
      mock_message(DROPBOX_EMAILS[:forwarded])
    end

    it "should not match the dropbox email address if routed to an alias" do
      @lead = create(:lead, email: "ben@example.com", access: "Public")
      @lead_dropbox = create(:lead, email: "dropbox@example.com", access: "Public")

      expect(@crawler).to receive(:archive).once
      @crawler.run

      expect(@lead_dropbox.emails.size).to eq(0)
      expect(@lead.emails.size).to eq(1)
    end
  end

  #------------------------------------------------------------------------------
  describe "Pipeline: creating recipient if s/he was not found" do
    before(:each) do
      mock_connect
      mock_disconnect
      create(:user, email: "aaron@example.com")
    end

    it "should create a contact from the email recipient (To: recipient, Bcc: dropbox)" do
      mock_message(DROPBOX_EMAILS[:plain])
      expect(@crawler).to receive(:archive).once
      @crawler.run

      @contact = Contact.first
      expect(@contact.email).to eq("ben@example.com")
      expect(@contact.emails.size).to eq(1)
      expect(@contact.emails.first.mediator).to eq(@contact)
    end

    it "should create a contact from the forwarded email (To: dropbox)" do
      mock_message(DROPBOX_EMAILS[:forwarded])
      expect(@crawler).to receive(:archive).once
      @crawler.run

      @contact = Contact.first
      expect(@contact.email).to eq("ben@example.com")
      expect(@contact.emails.size).to eq(1)
      expect(@contact.emails.first.mediator).to eq(@contact)
    end
  end

  #------------------------------------------------------------------------------
  describe "Extracting body" do
    before do
      @dropbox = FatFreeCRM::MailProcessor::Dropbox.new
    end

    it "should extract text from multipart text/plain" do
      text = @dropbox.send(:plain_text_body, Mail.new(DROPBOX_EMAILS[:plain]))
      expect(text).to be_present
    end

    it "should extract text and strip tags from multipart text/html" do
      text = @dropbox.send(:plain_text_body, Mail.new(DROPBOX_EMAILS[:html]))
      expect(text).to be_present
      expect(text).not_to match(/<\/?[^>]*>/)
    end
  end

  #------------------------------------------------------------------------------
  describe "Default values" do
    describe "'access'" do
      it "should be 'Private' if default setting is 'Private'" do
        allow(Setting).to receive(:default_access).and_return('Private')
        expect(@crawler.send(:default_access)).to eq("Private")
      end

      it "should be 'Public' if default setting is 'Public'" do
        allow(Setting).to receive(:default_access).and_return('Public')
        expect(@crawler.send(:default_access)).to eq("Public")
      end

      it "should be 'Private' if default setting is 'Shared'" do
        allow(Setting).to receive(:default_access).and_return('Shared')
        expect(@crawler.send(:default_access)).to eq("Private")
      end
    end
  end
end
