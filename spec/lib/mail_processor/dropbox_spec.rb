require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.dirname(__FILE__) + '/sample_emails/dropbox'

require "fat_free_crm/mail_processor/dropbox"

describe FatFreeCRM::MailProcessor::Dropbox do
  include MockIMAP

  before do
    @mock_address = "dropbox@example.com"
  end

  before(:each) do
    @crawler = FatFreeCRM::MailProcessor::Dropbox.new
    @crawler.stub!("expunge!").and_return(true)
  end

  #------------------------------------------------------------------------------
  describe "Running the crawler" do
    before(:each) do
      mock_connect
      mock_disconnect
      mock_message(DROPBOX_EMAILS[:plain])
    end

    it "should discard a message if it's invalid" do
      @crawler.should_receive(:is_valid?).once.and_return(false)
      FactoryGirl.create(:user, :email => "aaron@example.com")
      @crawler.should_not_receive(:archive)
      @crawler.should_receive(:discard).once
      @crawler.run
    end

    it "should discard a message if it can't find the user" do
      @crawler.should_receive(:is_valid?).once.and_return(true)
      @crawler.should_not_receive(:archive)
      @crawler.should_receive(:discard).once
      @crawler.run
    end

    it "should process a message if it finds the user" do
      FactoryGirl.create(:user, :email => "aaron@example.com")
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:discard)
      @crawler.run
    end
  end

  #------------------------------------------------------------------------------
  describe "Pipeline: processing keywords on the first line" do
    before(:each) do
      mock_connect
      mock_disconnect
      FactoryGirl.create(:user, :email => "aaron@example.com")
    end

    it "should find the named asset and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line])
      @campaign = FactoryGirl.create(:campaign, :name => "Got milk!?")
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @campaign.emails.size.should == 1
      @campaign.emails.first.mediator.should == @campaign
    end

    it "should create the named asset and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line])
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @campaign = Campaign.first(:conditions => "name = 'Got milk'")
      @campaign.should be_instance_of(Campaign)
      @campaign.emails.size.should == 1
      @campaign.emails.first.mediator.should == @campaign
    end

    it "should find the lead and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line_lead])
      @lead = FactoryGirl.create(:lead, :first_name => "Cindy", :last_name => "Cluster")
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @lead.emails.size.should == 1
      @lead.emails.first.mediator.should == @lead
    end

    it "should create the lead and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line_lead])
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @lead = Lead.first(:conditions => "first_name = 'Cindy' AND last_name = 'Cluster'")
      @lead.should be_instance_of(Lead)
      @lead.status.should == "contacted"
      @lead.emails.size.should == 1
      @lead.emails.first.mediator.should == @lead
    end

    it "should find the contact and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line_contact])
      @contact = FactoryGirl.create(:contact, :first_name => "Cindy", :last_name => "Cluster")
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @contact.emails.size.should == 1
      @contact.emails.first.mediator.should == @contact
    end

    it "should create the contact and attach the email message" do
      mock_message(DROPBOX_EMAILS[:first_line_contact])
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @contact = Contact.first(:conditions => "first_name = 'Cindy' AND last_name = 'Cluster'")
      @contact.should be_instance_of(Contact)
      @contact.emails.size.should == 1
      @contact.emails.first.mediator.should == @contact
    end

    it "should move on if first line has no keyword" do
      mock_message(DROPBOX_EMAILS[:plain])
      @crawler.should_receive(:with_recipients).twice
      @crawler.should_receive(:with_forwarded_recipient).twice
      @crawler.run
    end
  end

  #------------------------------------------------------------------------------
  describe "Pipieline: processing recipients (To: recipient, Bcc: dropbox)" do
    before(:each) do
      mock_connect
      mock_disconnect
      mock_message(DROPBOX_EMAILS[:plain])
      FactoryGirl.create(:user, :email => "aaron@example.com")
    end

    it "should find the asset and attach the email message" do
      @lead = FactoryGirl.create(:lead, :email => "ben@example.com", :access => "Public")
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_forwarded_recipient)
      @crawler.run

      @lead.emails.size.should == 1
      @lead.emails.first.mediator.should == @lead
    end

    it "should move on if asset recipients did not match" do
      @crawler.should_receive(:with_recipients).twice
      @crawler.should_receive(:with_forwarded_recipient).twice
      @crawler.run
    end
  end

  #------------------------------------------------------------------------------
  describe "Pipieline: processing forwarded recipient (To: dropbox)" do
    before(:each) do
      mock_connect
      mock_disconnect
      FactoryGirl.create(:user, :email => "aaron@example.com")
      mock_message(DROPBOX_EMAILS[:forwarded])
    end

    it "should find the asset and attach the email message" do
      @lead = FactoryGirl.create(:lead, :email => "ben@example.com", :access => "Public")
      @crawler.should_receive(:archive).once
      @crawler.run

      @lead.emails.size.should == 1
      @lead.emails.first.mediator.should == @lead
    end

    it "should touch the asset" do
      now = Time.zone.now
      timezone = ActiveRecord::Base.default_timezone
      begin
        ActiveRecord::Base.default_timezone = :utc
        @lead = FactoryGirl.create(:lead, :email => "ben@example.com", :access => "Public", :updated_at => 5.day.ago)

        @crawler.run
        @lead.reload.updated_at.to_i.should >= now.to_i
      ensure
        ActiveRecord::Base.default_timezone = timezone
      end
    end

    it "should change lead's status (:new => :contacted)" do
      @lead = FactoryGirl.create(:lead, :email => "ben@example.com", :access => "Public", :status => "new")

      @crawler.run
      @lead.reload.status.should == "contacted"
    end

    it "should move on if forwarded recipient did not match" do
      @crawler.should_receive(:with_forwarded_recipient).twice
      @crawler.run
    end
  end

  #------------------------------------------------------------------------------
  describe "Pipieline: creating recipient if s/he was not found" do
    before(:each) do
      mock_connect
      mock_disconnect
      FactoryGirl.create(:user, :email => "aaron@example.com")
    end

    it "should create a contact from the email recipient (To: recipient, Bcc: dropbox)" do
      mock_message(DROPBOX_EMAILS[:plain])
      @crawler.should_receive(:archive).once
      @crawler.run

      @contact = Contact.first
      @contact.email.should == "ben@example.com"
      @contact.emails.size.should == 1
      @contact.emails.first.mediator.should == @contact
    end

    it "should create a contact from the forwarded email (To: dropbox)" do
      mock_message(DROPBOX_EMAILS[:forwarded])
      @crawler.should_receive(:archive).once
      @crawler.run

      @contact = Contact.first
      @contact.email.should == "ben@example.com"
      @contact.emails.size.should == 1
      @contact.emails.first.mediator.should == @contact
    end
  end

  #------------------------------------------------------------------------------

  describe "Default values" do

    describe "'access'" do

      it "should be 'Private' if default setting is 'Private'" do
        Setting.stub!(:default_access).and_return('Private')
        @crawler.send(:default_access).should == "Private"
      end

      it "should be 'Public' if default setting is 'Public'" do
        Setting.stub!(:default_access).and_return('Public')
        @crawler.send(:default_access).should == "Public"
      end

      it "should be 'Private' if default setting is 'Shared'" do
        Setting.stub!(:default_access).and_return('Shared')
        @crawler.send(:default_access).should == "Private"
      end

    end

  end

end

