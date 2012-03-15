require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fat_free_crm/mailman'

describe FatFreeCRM::Mailman do
  it "should route comment reply email to SubscriptionMailer#new_comment" do
    mail = Mail.new(:from => "test@example.com",
                    :to   => "reply-contact-1234@example.com")

    # Test that message is routed to SubscriptionMailer
    SubscriptionMailer.should_receive(:new_comment).
                       with(mail, {
                            "entity" => "contact",
                            "id"     => "1234",
                            "domain" => "example.com"
                       })

    FatFreeCRM::Mailman.router.route(mail)

  end
end
