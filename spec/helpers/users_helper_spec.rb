require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersHelper do

  let(:myself) { FactoryGirl.create(:user, :id => 54)}
  let(:user1) { FactoryGirl.create(:user,  :id => 60, :first_name => 'Bob', :last_name => "Hope") }
  let(:user2) { FactoryGirl.create(:user,  :id => 75, :first_name => 'Billy', :last_name => "Joel") }

  describe "user_options_for_select" do
    it "includes 'myself'" do
      user_options_for_select([user1, user2], myself).should include(["Myself", 54])
    end

    it "includes other users" do
      user_options_for_select([user1, user2], myself).should include(["Bob Hope", 60], ["Billy Joel", 75])
    end
  end

  describe "user_select" do
    it "includes blank option" do
      user_select(:lead, [user1, user2], myself).should match(/<option value="">Unassigned<\/option>/)
    end

    it "includes myself" do
      user_select(:lead, [user1, user2], myself).should match(/<option value="54">Myself<\/option>/)
    end

    it "includes other users" do
      user_select(:lead, [user1, user2], myself).should match(/<option value="60">Bob Hope<\/option>/)
      user_select(:lead, [user1, user2], myself).should match(/<option value="75">Billy Joel<\/option>/)
    end
  end
end

