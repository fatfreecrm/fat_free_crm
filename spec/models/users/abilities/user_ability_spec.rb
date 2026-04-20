# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'
require 'cancan/matchers'

def all_actions
  %i[index show create update destroy manage]
end

describe User do
  subject(:ability)  { Ability.new(user) }
  let(:subject_user) { build :user }

  context "when site manager, I" do
    let(:user)  { build :user, admin: true }
    all_actions.each do |do_action|
      it { is_expected.to be_able_to(do_action, subject_user) }
    end
  end

  context "when myself, I" do
    let(:user) { build :user }
    let(:subject_user) { user }
    all_actions.each do |do_action|
      it { is_expected.to be_able_to(do_action, subject_user) }
    end
  end

  context "when another user, I" do
    let(:user)  { create :user }
    let(:can)    { [] }
    let(:cannot) { %i[show create update index destroy manage] }
    it do
      can.each do |do_action|
        is_expected.to be_able_to(do_action, subject_user)
      end
    end
    it do
      cannot.each do |do_action|
        is_expected.not_to be_able_to(do_action, subject_user)
      end
    end
  end

  context "when anonymous user, I" do
    let(:user)  { nil }
    let(:can)    { [] }
    let(:cannot) { %i[show create update index destroy manage] }
    it do
      can.each do |do_action|
        is_expected.to be_able_to(do_action, subject_user)
      end
    end
    it do
      cannot.each do |do_action|
        is_expected.not_to be_able_to(do_action, subject_user)
      end
    end

    it "and signup enabled" do
      allow(User).to receive(:can_signup?).and_return(true)
      is_expected.to be_able_to(:create, User)
    end
  end

  context "Tag creation" do
    let(:user) { create :user, admin: false }

    it "allows tag creation by default" do
      allow(Setting).to receive(:admin_only_tag_creation).and_return(false)
      is_expected.to be_able_to(:create, Tag)
    end

    it "disallows tag creation for non-admins when admin_only_tag_creation is enabled" do
      allow(Setting).to receive(:admin_only_tag_creation).and_return(true)
      is_expected.not_to be_able_to(:create, Tag)
    end

    it "allows tag creation for admins even when admin_only_tag_creation is enabled" do
      user.update(admin: true)
      allow(Setting).to receive(:admin_only_tag_creation).and_return(true)
      is_expected.to be_able_to(:create, Tag)
    end
  end
end
