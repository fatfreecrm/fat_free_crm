require 'spec_helper'
require 'cancan/matchers'

def all_actions
  [:index, :show, :create, :update, :destroy, :manage]
end

describe "User abilities" do
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
    let(:cannot) { [:show, :create, :update, :index, :destroy, :manage] }
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
    let(:cannot) { [:show, :create, :update, :index, :destroy, :manage] }
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
end
