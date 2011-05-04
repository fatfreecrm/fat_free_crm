require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResourceObserver do
  
  [:account, :lead, :opportunity, :contact].each do |resource_type|
    describe "after_create" do
      context "if #{resource_type} has been assigned_to a user" do
        it "calls deliver_assigned_to_#{resource_type}_email_notification UserMailer" do
          UserMailer.should_receive("deliver_assigned_to_#{resource_type}_email_notification")
          Factory(resource_type, :assignee => Factory(:user))
        end
      end

      context "if #{resource_type} has NOT been assigned to a user" do
        it "should NOT call deliver_assigned_to_#{resource_type}_email_notification" do
          UserMailer.should_not_receive("deliver_assigned_to_#{resource_type}_email_notification")
          Factory(resource_type, :assignee => nil)
        end
      end
    end

    describe "after_update" do
      context "if #{resource_type} has been re-assigned_to a user" do
        it "calls deliver_assigned_to_#{resource_type}_email_notification UserMailer" do
          resource = Factory(resource_type, :assignee => Factory(:user))
          new_assignee = Factory(:user)
          UserMailer.should_receive("deliver_assigned_to_#{resource_type}_email_notification")
          resource.update_attributes(:assignee => new_assignee)
        end
      end
      
      context "if #{resource_type} has NOT been re-assigned to a user" do
        it "should NOT call deliver_assigned_to_#{resource_type}_email_notification" do
          resource = Factory(resource_type, :assignee => Factory(:user))
          UserMailer.should_not_receive("deliver_assigned_to_#{resource_type}_email_notification")
          resource.touch
        end
      end
    end
  end
end