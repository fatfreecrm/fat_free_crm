# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentNotificationJob do
  let(:subscriber) { create(:user) }
  let(:entity) { create(:lead, subscribed_users: [subscriber.id]) }
  let(:comment) { create(:comment, commentable: entity) }

  before(:each) do
    allow(SubscriptionMailer).to receive_message_chain(:comment_notification, :deliver_now)
  end

  it "should notify subscribers when a comment is added" do
    CommentNotificationJob.perform_now(comment)
    expect(SubscriptionMailer).to have_received(:comment_notification).with(subscriber, comment)
  end

  it "should not notify the user who created the comment" do
    user = comment.user
    entity.update(subscribed_users: [subscriber.id, user.id])
    CommentNotificationJob.perform_now(comment)
    expect(SubscriptionMailer).not_to have_received(:comment_notification).with(user, comment)
  end

  it "should not notify suspended users" do
    subscriber.update(suspended_at: Time.now)
    CommentNotificationJob.perform_now(comment)
    expect(SubscriptionMailer).not_to have_received(:comment_notification).with(subscriber, comment)
  end

  it "should not notify users awaiting approval" do
    subscriber.update(sign_in_count: 0, suspended_at: Time.now)
    allow(Setting).to receive(:user_signup).and_return(:needs_approval)
    CommentNotificationJob.perform_now(comment)
    expect(SubscriptionMailer).not_to have_received(:comment_notification).with(subscriber, comment)
  end

  it "should not notify users who opted out of comment replies" do
    subscriber.update(subscribe_to_comment_replies: false)
    CommentNotificationJob.perform_now(comment)
    expect(SubscriptionMailer).not_to have_received(:comment_notification).with(subscriber, comment)
  end
end
