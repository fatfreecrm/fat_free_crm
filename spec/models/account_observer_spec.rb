require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountObserver do

  describe "after_create" do
    context "if account has been assigned_to a user" do
      it "calls deliver_assigned_to_account_notification UserMailer" do
        UserMailer.should_receive(:deliver_assigned_to_account_notification)
        Factory(:account, :assignee => Factory(:user))
      end
    end

    context "if account has NOT been assigned to a user" do
      it "UserMailer should NOT receive deliver_assigned_to_account_notification" do
        UserMailer.should_not_receive(:deliver_assigned_to_account_notification)
        Factory(:account, :assignee => nil)
      end
    end
  end

  describe "after_update" do
    context "if account has been re-assigned_to a user" do
      it "calls deliver_assigned_to_account_notification UserMailer" do
        account = Factory(:account, :assignee => Factory(:user))
        new_assignee = Factory(:user)
        UserMailer.should_receive(:deliver_assigned_to_account_notification)
        account.update_attributes(:assignee => new_assignee)
      end
    end
      
    context "if account has NOT been re-assigned to a user" do
      it "UserMailer should NOT receive deliver_assigned_to_account_notification" do
        account = Factory(:account, :assignee => Factory(:user))
        UserMailer.should_not_receive(:deliver_assigned_to_account_notification)
        account.update_attributes(:name => "new_account_name")
      end
    end
  end

end