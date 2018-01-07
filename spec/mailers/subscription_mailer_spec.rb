# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe SubscriptionMailer do
  describe "comment notification" do
    let(:user) { build(:user, email: 'notify_me@example.com') }
    let(:campaign) { build(:campaign, user: user) }
    let(:account) { build(:account, user: user) }
    let(:commentable) { build_stubbed(:opportunity, id: 47, name: 'Opportunity name', account: account, campaign: campaign, user: user) }
    let(:comment) { build(:comment, commentable: commentable, user: user) }
    let(:mail) { SubscriptionMailer.comment_notification(user, comment) }

    it "sets user 'notify_me@example.com' as recipient" do
      expect(mail.to).to eq(["notify_me@example.com"])
    end

    it "sets the subject" do
      expect(mail.subject).to eq("RE: [opportunity:47] Opportunity name")
    end

    it "includes link to opportunity in body" do
      expect(mail.body.encoded).to match('http://www.example.com/opportunities/47')
    end

    it "uses email defined in settings as the sender" do
      allow(Setting).to receive(:dig).with(:email_comment_replies, :address).and_return("email_comment_reply@example.com")
      expect(mail.from).to eql(["email_comment_reply@example.com"])
    end

    it "should fallback to smtp from address as the sender" do
      allow(Setting).to receive(:dig).with(:email_comment_replies, :address).and_return("")
      allow(Setting).to receive(:dig).with(:smtp, :from).and_return("smtp_from@example.com")
      expect(mail.from).to eql(["smtp_from@example.com"])
    end

    it "should set default reply-to address if email doesn't exist" do
      allow(Setting).to receive(:dig).with(:email_comment_replies, :address).and_return("")
      allow(Setting).to receive(:dig).with(:smtp, :from).and_return("")
      expect(mail.from).to eql(["noreply@fatfreecrm.com"])
    end
  end
end
