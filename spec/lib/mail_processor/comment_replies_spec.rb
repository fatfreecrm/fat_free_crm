require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.dirname(__FILE__) + '/sample_emails/comment_replies'

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

@user = FactoryGirl.create(:user)
@contact = FactoryGirl.create(:contact)

comment_body = 'This comment should be added to the associated contact'

mail = Mail.new(:from    => @user.email,
                :to      => "crm-comment@example.com",
                :subject => "RE: [contact:#{@contact.id}] John Smith",
                :body    => comment_body)

##### FatFreeCRM::Mailman.new.router.route(mail)

@contact.comments.size.should == 1
c = @contact.comments.first
c.user.should == @user
c.comment.should include(comment_body)
