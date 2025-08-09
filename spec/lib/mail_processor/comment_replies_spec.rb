# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require "fat_free_crm/mail_processor/comment_replies"

describe FatFreeCRM::MailProcessor::CommentReplies do
  include MockIMAP

  before do
    @mock_address = "crm-comment@example.com"
  end

  before(:each) do
    @crawler = FatFreeCRM::MailProcessor::CommentReplies.new
  end

  #------------------------------------------------------------------------------
  describe "Processing new emails" do
    before do
      create(:user, email: "aaron@example.com")
    end

    before(:each) do
      mock_connect
      mock_disconnect
    end

    it "should attach a new comment to a contact" do
      @contact = create(:contact)
      comment_reply = "This is a new comment reply via email"

      mail = Mail.new from:    "Aaron Assembler <aaron@example.com>",
                      to:      "FFCRM Comments <crm-commment@example.com>",
                      subject: "[contact:#{@contact.id}] Test Contact",
                      body:    comment_reply
      mock_message mail.to_s

      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:with_recipients)
      @crawler.run

      expect(@contact.comments.size).to eq(1)
      expect(@contact.comments.first.comment).to eq(comment_reply)
    end

    it "should attach a new comment to an opportunity, using the 'op' shortcut in subject" do
      @opportunity = create(:opportunity)
      comment_reply = "This is a new comment reply via email"

      mail = Mail.new from:    "Aaron Assembler <aaron@example.com>",
                      to:      "FFCRM Comments <crm-commment@example.com>",
                      subject: "[op:#{@opportunity.id}] Test Opportunity",
                      body:    comment_reply
      mock_message mail.to_s

      expect(@crawler).to receive(:archive).once
      expect(@crawler).not_to receive(:with_recipients)
      @crawler.run

      expect(@opportunity.comments.size).to eq(1)
      expect(@opportunity.comments.first.comment).to eq(comment_reply)
    end
  end
end
