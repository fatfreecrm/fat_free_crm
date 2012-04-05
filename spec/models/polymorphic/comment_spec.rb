# == Schema Information
#
# Table name: comments
#
#  id               :integer         not null, primary key
#  user_id          :integer
#  commentable_id   :integer
#  commentable_type :string(255)
#  private          :boolean
#  title            :string(255)     default("")
#  comment          :text
#  created_at       :datetime
#  updated_at       :datetime
#  state            :string(16)      default("Expanded"), not null
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Comment do

  before(:each) do
    login
  end

  it "should create a new instance given valid attributes" do
    Comment.create!(:comment => "Hello", :user => FactoryGirl.create(:user), :commentable => FactoryGirl.create(:lead))
  end

  it "should subscribe users mentioned in the comment to the entity, and notify them via email" do
    expected_users = [
      FactoryGirl.create(:user, :username => "test_user"),
      FactoryGirl.create(:user, :username => "another_user")
    ]
    entity = FactoryGirl.create(:lead)
    Comment.create!(:comment => "Hey @test_user, take a look at this. Also show @another_user",
                    :user => FactoryGirl.create(:user),
                    :commentable => entity)

    expected_users.each do |user|
      entity.subscribed_users.should include(user.id)
    end
  end
end

