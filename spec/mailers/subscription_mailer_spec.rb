require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SubscriptionMailer do

  describe "comment notification" do
    let(:user) { FactoryGirl.create(:user) }
    let(:commentable) { FactoryGirl.create(:opportunity, :id => 47, :name => 'Opportunity name') }
    let(:comment) { FactoryGirl.create(:comment, :commentable => commentable) }
    let(:mail) { SubscriptionMailer.comment_notification(user, comment) }

    it "send user password reset url" do
      mail.subject.should eq("RE: [opportunity:47] Opportunity name")
      mail.to.should eq([user.email])
      mail.body.encoded.should match(polymorphic_url(commentable))
    end
  end
end
