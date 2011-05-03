require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include ActionController::UrlWriter

describe UserMailer do

  describe "assigned_to_account_notification" do
    before :each do
      @assigner = Factory(:user, :first_name => "mike", :last_name => "reid", :email => "mike_reid@example.com")
      @assignee = Factory(:user, :first_name => "john", :last_name => "manne", :email => "john_manne@example.com")
      @account = Factory(:account, :name => "Mastermind", :user => @assigner, :assignee => @assignee)
      @email = UserMailer.create_assigned_to_account_notification(@account)
    end
    
    it "should have the correct subject" do
      @email.should have_subject("You have been assigned #{@account.name} Account in CRM")
    end
    
    it "should have the correct body" do
      @email.should have_body_text("Your colleague #{@assigner.full_name} has assigned you Account #{@account.name}")
      @email.should have_body_text(account_url(@account.id, :protocol => 'https', :host => "crm.unboxedconsulting.com"))
      @email.should have_body_text("Please check the record is as complete as possible.")
      @email.should have_body_text("Love CRM.")
    end  
    
    it "should have the correct recipient" do
      @email.should deliver_to(@assignee.email)
    end
    
    it "should have the correct reply-to" do
      @email.should reply_to(@assigner.email)
    end
    
    it "should have the correct sender" do
      @email.should deliver_from("CRM <crm@unboxedconsulting.com>")
    end
    
  end
end