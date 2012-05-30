require 'spec_helper'

describe UserMailer do
  describe "password_reset_instructions" do
    let(:user) { FactoryGirl.create(:user, :email => "forgot_my_password@example.com") }
    let(:mail) { UserMailer.password_reset_instructions(user) }

    before(:each) do
      I18n.stub(:t).with(:password_reset_instruction).and_return("Password Reset Instructions")
      user.stub(:perishable_token).and_return("62fe5299b45513f9d22a2e1454f35dd43d62ba50")
    end

    it "sets fatfree as the sender" do
      mail.from.should eql(["noreply@fatfreecrm.com"])
    end

    it "sets user 'forgot_my_password@example.com' as recipient" do
      mail.to.should eq(["forgot_my_password@example.com"])
    end

    it "sets the subject" do
      mail.subject.should eq("Fat Free CRM: Password Reset Instructions")
    end

    it "includes password reset link in body" do
      mail.body.encoded.should match("http://www.example.com/passwords/62fe5299b45513f9d22a2e1454f35dd43d62ba50/edit")
    end
  end
end