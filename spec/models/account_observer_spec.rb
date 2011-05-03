require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountObserver do

  describe "after_create" do
    context "if account has been assigned_to a user" do
      it "calls deliver_assigned_to_account_notification UserMailer" do
        UserMailer.should_receive(:deliver_assigned_to_account_notification)
        Factory(:account, :assigned_to => Factory(:user))
      end
    end
    
    context "if account has NOT been assigned to a user" do
      it "UserMailer should NOT receive deliver_assigned_to_account_notification" do
        UserMailer.should_not_receive(:deliver_assigned_to_account_notification)
        Factory(:account, :assigned_to => nil)
      end
    end
  end

end