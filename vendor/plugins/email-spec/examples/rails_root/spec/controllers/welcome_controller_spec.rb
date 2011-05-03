require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WelcomeController do

  describe "POST /signup (#signup)" do
    it "should deliver the signup email" do
      # expect
      UserMailer.should_receive(:deliver_signup).with("email@example.com", "Jimmy Bean")
      # when
      post :signup, "Email" => "email@example.com", "Name" => "Jimmy Bean"
    end

  end

end
