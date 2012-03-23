require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.dirname(__FILE__) + '/dropbox/email_samples'

require "fat_free_crm/dropbox"

describe "IMAP Dropbox" do
  before(:each) do
    @crawler = FatFreeCRM::MailProcessor::Dropbox.new
    @crawler.stub!("expunge!").and_return(true)
  end

  def mock_imap
    @imap = mock
    @settings = @crawler.instance_variable_get("@settings")
    @settings[:address] = "dropbox@example.com"
    Net::IMAP.stub!(:new).with(@settings[:server], @settings[:port], @settings[:ssl]).and_return(@imap)
  end

  def mock_connect
    mock_imap
    @imap.stub!(:login).and_return(true)
    @imap.stub!(:select).and_return(true)
  end

  def mock_disconnect
    @imap.stub!(:disconnected?).and_return(false)
    @imap.stub!(:logout).and_return(true)
    @imap.stub!(:disconnect).and_return(true)
  end

  def mock_message(body = EMAIL[:plain])
    @fetch_data = mock
    @fetch_data.stub!(:attr).and_return("RFC822" => body)
    @imap.stub!(:uid_search).and_return([ :uid ])
    @imap.stub!(:uid_fetch).and_return([ @fetch_data ])
    @imap.stub!(:uid_copy).and_return(true)
    @imap.stub!(:uid_store).and_return(true)
    body
  end

  #------------------------------------------------------------------------------
  describe "Connecting to the IMAP server" do
    it "should connect to the IMAP server and login as user, and select folder" do
      mock_imap
      @imap.should_receive(:login).once.with(@settings[:user], @settings[:password])
      @imap.should_receive(:select).once.with(@settings[:scan_folder])
      @crawler.send(:connect!)
    end

    it "should connect to the IMAP server, login as user, but not select folder when requested so" do
      mock_imap
      @imap.should_receive(:login).once.with(@settings[:user], @settings[:password])
      @imap.should_not_receive(:select).with(@settings[:scan_folder])
      @crawler.send(:connect!, :setup => true)
    end

    it "should raise the error if connection fails" do
      Net::IMAP.should_receive(:new).and_raise(SocketError) # No mocks this time! :-)
      @crawler.send(:connect!).should == nil
    end
  end

  #------------------------------------------------------------------------------
  describe "Disconnecting from the IMAP server" do
    it "should logout and diconnect" do
      mock_connect
      mock_disconnect
      @imap.should_receive(:logout).once
      @imap.should_receive(:disconnect).once

      @crawler.send(:connect!)
      @crawler.send(:disconnect!)
    end
  end

  #------------------------------------------------------------------------------
  describe "Discarding a message" do
    before(:each) do
      mock_connect
      @uid = mock
      @crawler.send(:connect!)
    end

    it "should copy message to invalid folder if it's set and flag the message as deleted" do
      @settings[:move_invalid_to_folder] = "invalid"
      @imap.should_receive(:uid_copy).once.with(@uid, @settings[:move_invalid_to_folder])
      @imap.should_receive(:uid_store).once.with(@uid, "+FLAGS", [:Deleted])
      @crawler.send(:discard, @uid)
    end

    it "should not copy message to invalid folder if it's not set and flag the message as deleted" do
      @settings[:move_invalid_to_folder] = nil
      @imap.should_not_receive(:uid_copy)
      @imap.should_receive(:uid_store).once.with(@uid, "+FLAGS", [:Deleted])
      @crawler.send(:discard, @uid)
    end
  end

  #------------------------------------------------------------------------------
  describe "Archiving a message" do
    before(:each) do
      mock_connect
      @uid = mock
      @crawler.send(:connect!)
    end

    it "should copy message to archive folder if it's set and flag the message as seen" do
      @settings[:move_to_folder] = "processed"
      @imap.should_receive(:uid_copy).once.with(@uid, @settings[:move_to_folder])
      @imap.should_receive(:uid_store).once.with(@uid, "+FLAGS", [:Seen])
      @crawler.send(:archive, @uid)
    end

    it "should not copy message to archive folder if it's not set and flag the message as seen" do
      @settings[:move_to_folder] = nil
      @imap.should_not_receive(:uid_copy)
      @imap.should_receive(:uid_store).once.with(@uid, "+FLAGS", [:Seen])
      @crawler.send(:archive, @uid)
    end
  end

  #------------------------------------------------------------------------------
  describe "Validating email" do
    before(:each) do
      @email = mock
    end

    it "should be valid email if its contents type is text/plain" do
      @email.stub!(:content_type).and_return("text/plain")
      @crawler.send(:is_valid?, @email).should == true
    end

    it "should be invalid email if its contents type is not text/plain" do
      @email.stub!(:content_type).and_return("text/html")
      @crawler.send(:is_valid?, @email).should == false
    end
  end

  #------------------------------------------------------------------------------
  describe "Finding email sender among users" do
    before(:each) do
      @from = [ "Aaron@Example.Com", "Ben@Example.com" ]
      @email = mock
      @email.stub!(:from).and_return(@from)
    end

    it "should find non-suspended user that matches From: field" do
      @user = FactoryGirl.create(:user, :email => @from.first, :suspended_at => nil)
      @crawler.send(:sent_from_known_user?, @email).should == true
      @crawler.instance_variable_get("@sender").should == @user
    end

    it "should not find user if his email doesn't match From: field" do
      FactoryGirl.create(:user, :email => "nobody@example.com")
      @crawler.send(:sent_from_known_user?, @email).should == false
      @crawler.instance_variable_get("@sender").should == nil
    end

    it "should not find user if his email matches From: field but is suspended" do
      FactoryGirl.create(:user, :email => @from.first, :suspended_at => Time.now)
      @crawler.send(:sent_from_known_user?, @email).should == false
      @crawler.instance_variable_get("@sender").should == nil
    end
  end

  #------------------------------------------------------------------------------
  describe "Running the crawler" do
    before(:each) do
      mock_connect
      mock_disconnect
      mock_message
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
      mock_message(EMAIL[:first_line])
      @campaign = FactoryGirl.create(:campaign, :name => "Got milk!?")
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @campaign.emails.size.should == 1
      @campaign.emails.first.mediator.should == @campaign
    end

    it "should create the named asset and attach the email message" do
      mock_message(EMAIL[:first_line])
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @campaign = Campaign.first(:conditions => "name = 'Got milk'")
      @campaign.should be_instance_of(Campaign)
      @campaign.emails.size.should == 1
      @campaign.emails.first.mediator.should == @campaign
    end

    it "should find the lead and attach the email message" do
      mock_message(EMAIL[:first_line_lead])
      @lead = FactoryGirl.create(:lead, :first_name => "Cindy", :last_name => "Cluster")
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @lead.emails.size.should == 1
      @lead.emails.first.mediator.should == @lead
    end

    it "should create the lead and attach the email message" do
      mock_message(EMAIL[:first_line_lead])
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
      mock_message(EMAIL[:first_line_contact])
      @contact = FactoryGirl.create(:contact, :first_name => "Cindy", :last_name => "Cluster")
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @contact.emails.size.should == 1
      @contact.emails.first.mediator.should == @contact
    end

    it "should create the contact and attach the email message" do
      mock_message(EMAIL[:first_line_contact])
      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @contact = Contact.first(:conditions => "first_name = 'Cindy' AND last_name = 'Cluster'")
      @contact.should be_instance_of(Contact)
      @contact.emails.size.should == 1
      @contact.emails.first.mediator.should == @contact
    end

    it "should move on if first line has no keyword" do
      mock_message(EMAIL[:plain])
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
      mock_message(EMAIL[:plain])
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
      mock_message(EMAIL[:forwarded])
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
      mock_message(EMAIL[:plain])
      @crawler.should_receive(:archive).once
      @crawler.run

      @contact = Contact.first
      @contact.email.should == "ben@example.com"
      @contact.emails.size.should == 1
      @contact.emails.first.mediator.should == @contact
    end

    it "should create a contact from the forwarded email (To: dropbox)" do
      mock_message(EMAIL[:forwarded])
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

