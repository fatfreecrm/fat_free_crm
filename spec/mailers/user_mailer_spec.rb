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

  describe "assigned_entity_notification" do
    let(:assigner) { FactoryGirl.create(:user, :first_name => "Bob", :last_name => "Hope") }
    let(:assignee) { FactoryGirl.create(:user, :email => "assignee@example.com") }

    context "for an account" do
      let(:account) { FactoryGirl.create(:account, :id => 16, :name => 'Ghostbusters', :user => assigner, :assignee => assignee) }
      let(:mail) { UserMailer.assigned_entity_notification(account, assigner) }

      it "sets fatfree as the sender" do
        mail.from.should eql(["notifications@fatfreecrm.com"])
      end

      it "sets user 'assignee@example.com' as recipient" do
        mail.to.should eq(["assignee@example.com"])
      end

      it "sets the subject" do
        mail.subject.should eq("Fat Free CRM: You have been assigned Ghostbusters Account")
      end

      it "includes the name of the person who re-assigned the lead in the body" do
        mail.body.encoded.should match("Bob")
      end

      it "includes link to the lead in the body" do
        mail.body.encoded.should match("http://www.example.com/accounts/16")
      end
    end

    context "for a contact" do
      let(:contact) { FactoryGirl.create(:contact, :id => 56, :first_name => 'Harold', :last_name => 'Ramis', :user => assigner, :assignee => assignee) }
      let(:mail) { UserMailer.assigned_entity_notification(contact, assigner) }

      it "sets fatfree as the sender" do
        mail.from.should eql(["notifications@fatfreecrm.com"])
      end

      it "sets user 'assignee@example.com' as recipient" do
        mail.to.should eq(["assignee@example.com"])
      end

      it "sets the subject" do
        mail.subject.should eq("Fat Free CRM: You have been assigned Harold Ramis Contact")
      end

      it "includes the name of the person who re-assigned the lead in the body" do
        mail.body.encoded.should match("Bob")
      end

      it "includes link to the lead in the body" do
        mail.body.encoded.should match("http://www.example.com/contacts/56")
      end
    end

    context "for a lead" do
      let(:lead) { FactoryGirl.create(:lead, :id => 42, :first_name => 'Bill', :last_name => 'Murray', :user => assigner, :assignee => assignee) }
      let(:mail) { UserMailer.assigned_entity_notification(lead, assigner) }

      it "sets fatfree as the sender" do
        mail.from.should eql(["notifications@fatfreecrm.com"])
      end

      it "sets user 'assignee@example.com' as recipient" do
        mail.to.should eq(["assignee@example.com"])
      end

      it "sets the subject" do
        mail.subject.should eq("Fat Free CRM: You have been assigned Bill Murray Lead")
      end

      it "includes the name of the person who re-assigned the lead in the body" do
        mail.body.encoded.should match("Bob")
      end

      it "includes link to the lead in the body" do
        mail.body.encoded.should match("http://www.example.com/leads/42")
      end
    end

    context "for an opportunity" do
      let(:opportunity) { FactoryGirl.create(:opportunity, :id => 24, :name => 'Big', :user => assigner, :assignee => assignee) }
      let(:mail) { UserMailer.assigned_entity_notification(opportunity, assigner) }

      it "sets fatfree as the sender" do
        mail.from.should eql(["notifications@fatfreecrm.com"])
      end

      it "sets user 'assignee@example.com' as recipient" do
        mail.to.should eq(["assignee@example.com"])
      end

      it "sets the subject" do
        mail.subject.should eq("Fat Free CRM: You have been assigned Big Opportunity")
      end

      it "includes the name of the person who re-assigned the lead in the body" do
        mail.body.encoded.should match("Bob")
      end

      it "includes link to the lead in the body" do
        mail.body.encoded.should match("http://www.example.com/opportunities/24")
      end
    end
  end
end