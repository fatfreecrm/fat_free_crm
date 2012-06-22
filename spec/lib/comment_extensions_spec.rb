require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FatFreeCRM::CommentExtensions do
  describe "add_comment_by_user" do
    let(:user) { FactoryGirl.create(:user)}

    before :each do
      build_model(:commentable_entity) do
        string :subscribed_users
        serialize :subscribed_users, Set

        acts_as_commentable
        uses_comment_extensions
      end
    end

    it "should create a comment for user" do
      entity = CommentableEntity.create
      entity.add_comment_by_user("I will handle this one", user)
      entity.reload.comments.map(&:comment).should include("I will handle this one")
    end

    it "should not create a comment if body is blank" do
      entity = CommentableEntity.create
      entity.add_comment_by_user("", user)
      entity.reload.comments.should be_empty
    end
  end
end
