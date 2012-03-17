require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fat_free_crm/mailman'

describe SubscriptionMailer do

  describe "processing new comments received via email" do

    it "should add a comment to a contact" do
      @user = FactoryGirl.create(:user)
      @contact = FactoryGirl.create(:contact)

      comment_body = 'This comment should be added to the associated contact'

      mail = Mail.new(:from    => @user.email,
                      :to      => "reply-contact-#{@contact.id}@default.com",
                      :subject => 'RE: Test Contact Comment',
                      :body    => comment_body)

      FatFreeCRM::Mailman.new.router.route(mail)

      @contact.comments.size.should == 1
      c = @contact.comments.first
      c.user.should == @user
      c.comment.should include(comment_body)
    end
  end
end
