# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'
require File.dirname(__FILE__) + '/sample_emails/dropbox'

require "fat_free_crm/mail_processor/base"

describe FatFreeCRM::MailProcessor::Base do
  include MockIMAP

  before do
    @mock_address = "base-mail-processor@example.com"
  end

  before(:each) do
    @crawler = FatFreeCRM::MailProcessor::Base.new
    # MailProcessor::Base doesn't load any settings by default
    @crawler.instance_variable_set "@settings", {
      :server   => "example.com",
      :port     => "123",
      :ssl      => true,
      :address  => "test@example.com",
      :user     => "test@example.com",
      :password => "123"
    }
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
      @uid = double
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
      @uid = double
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
      @email = double
    end

    it "should be valid email if its contents type is text/plain" do
      @email.stub(:content_type).and_return("text/plain")
      @crawler.send(:is_valid?, @email).should == true
    end

    it "should be invalid email if its contents type is not text/plain" do
      @email.stub(:content_type).and_return("text/html")
      @crawler.send(:is_valid?, @email).should == false
    end
  end

  #------------------------------------------------------------------------------
  describe "Finding email sender among users" do
    before(:each) do
      @from = [ "Aaron@Example.Com", "Ben@Example.com" ]
      @email = double
      @email.stub(:from).and_return(@from)
    end

    it "should find non-suspended user that matches From: field" do
      @user = create(:user, email: @from.first, suspended_at: nil)
      @crawler.send(:sent_from_known_user?, @email).should == true
      @crawler.instance_variable_get("@sender").should == @user
    end

    it "should not find user if his email doesn't match From: field" do
      create(:user, email: "nobody@example.com")
      @crawler.send(:sent_from_known_user?, @email).should == false
      @crawler.instance_variable_get("@sender").should == nil
    end

    it "should not find user if his email matches From: field but is suspended" do
      create(:user, email: @from.first, suspended_at: Time.now)
      @crawler.send(:sent_from_known_user?, @email).should == false
      @crawler.instance_variable_get("@sender").should == nil
    end

    #------------------------------------------------------------------------------
    describe "Extracting plain text body" do

      it "should extract text from multipart text/plain" do
        text = @crawler.send(:plain_text_body, Mail.new(DROPBOX_EMAILS[:plain]))
        text.should be_present
      end

      it "should extract text and strip tags from multipart text/html" do
        text = @crawler.send(:plain_text_body, Mail.new(DROPBOX_EMAILS[:multipart]))
        text.should eql('Hello,')
      end
    end
  end
end
