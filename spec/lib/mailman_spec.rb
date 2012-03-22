require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
