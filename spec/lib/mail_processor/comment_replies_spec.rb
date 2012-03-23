require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.dirname(__FILE__) + '/sample_emails/comment_replies'

require "fat_free_crm/mail_processor/comment_replies"

describe FatFreeCRM::MailProcessor::CommentReplies do
  include MockIMAP

  before do
    @mock_address = "crm-comment@example.com"
  end

  before(:each) do
    @crawler = FatFreeCRM::MailProcessor::Dropbox.new
    @crawler.stub!("expunge!").and_return(true)
  end




##### MOVE TO CommentInbox Spec

describe "Mailman" do
  xit "should route comment reply email to SubscriptionMailer#new_comment" do
    mail = Mail.new(:from => "test@example.com",
                    :to   => "crm-comment@example.com",
                    :subject => "RE: [contact:1234] John Smith")

    # Test that message is routed to SubscriptionMailer
    SubscriptionMailer.should_receive(:new_comment).
                       with(mail, "contact", "1234")

    ##### FatFreeCRM::Mailman.new.router.route(mail)

  end
end
