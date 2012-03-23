require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require "fat_free_crm/mail_processor/comment_replies"

describe FatFreeCRM::MailProcessor::CommentReplies do
  include MockIMAP

  before do
    @mock_address = "crm-comment@example.com"
  end

  before(:each) do
    @crawler = FatFreeCRM::MailProcessor::CommentReplies.new
    @crawler.stub!("expunge!").and_return(true)
  end

  #------------------------------------------------------------------------------
  describe "Processing new emails" do
    before(:each) do
      mock_connect
      mock_disconnect
      FactoryGirl.create(:user, :email => "aaron@example.com")
    end

    it "should attach a new comment to a contact" do
      @contact = FactoryGirl.create(:contact)
      comment_reply = "This is a new comment reply via email"

      mail = Mail.new :from    => "Aaron Assembler <aaron@example.com>",
                      :to      => "FFCRM Comments <crm-commment@example.com>",
                      :subject => "[contact:#{@contact.id}] Test Contact",
                      :body    => comment_reply
      mock_message mail.to_s

      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @contact.comments.size.should == 1
      @contact.comments.first.comment.should == comment_reply
    end

    it "should attach a new comment to an opportunity, using the 'op' shortcut in subject" do
      @opportunity = FactoryGirl.create(:opportunity)
      comment_reply = "This is a new comment reply via email"

      mail = Mail.new :from    => "Aaron Assembler <aaron@example.com>",
                      :to      => "FFCRM Comments <crm-commment@example.com>",
                      :subject => "[op:#{@opportunity.id}] Test Opportunity",
                      :body    => comment_reply
      mock_message mail.to_s

      @crawler.should_receive(:archive).once
      @crawler.should_not_receive(:with_recipients)
      @crawler.run

      @opportunity.comments.size.should == 1
      @opportunity.comments.first.comment.should == comment_reply
    end
  end
end
