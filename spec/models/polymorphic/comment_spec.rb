# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
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
  it "should create a new instance given valid attributes" do
    Comment.create!(comment: "Hello", user: create(:user), commentable: create(:lead))
  end

  it "should subscribe users mentioned in the comment to the entity, and notify them via email" do
    expected_users = [
      create(:user, username: "test_user"),
      create(:user, username: "another_user")
    ]
    entity = create(:lead)
    Comment.create!(comment: "Hey @test_user, take a look at this. Also show @another_user",
                    user: create(:user),
                    commentable: entity)

    expected_users.each do |user|
      expect(entity.subscribed_users).to include(user.id)
    end
  end

  describe "notify_subscribers" do
    let(:subscriber) { create(:user) }
    let(:entity) { create(:lead, subscribed_users: [subscriber.id]) }
    before(:each) do
      allow(SubscriptionMailer).to receive_message_chain(:comment_notification, :deliver_later)
    end

    it "should notify subscribers when a comment is added" do
      Comment.create!(comment: "Hello", user: create(:user), commentable: entity)
      expect(SubscriptionMailer).to have_received(:comment_notification).with(subscriber, instance_of(Comment))
    end

    it "should not notify the user who created the comment" do
      user = create(:user, confirmed_at: Time.now, email: "user@example.com")
      Comment.create!(comment: "Hello", user: user, commentable: entity)
      expect(SubscriptionMailer).not_to have_received(:comment_notification).with(user, instance_of(Comment))
    end

    it "should not notify suspended users" do
      subscriber.update(suspended_at: Time.now)
      Comment.create!(comment: "Hello", user: create(:user), commentable: entity)
      expect(SubscriptionMailer).not_to have_received(:comment_notification).with(subscriber, instance_of(Comment))
    end

    it "should not notify users awaiting approval" do
      subscriber.update(sign_in_count: 0, suspended_at: Time.now)
      allow(Setting).to receive(:user_signup).and_return(:not_allowed)
      Comment.create!(comment: "Hello", user: create(:user), commentable: entity)
      expect(SubscriptionMailer).not_to have_received(:comment_notification).with(subscriber, instance_of(Comment))
    end
  end
end
