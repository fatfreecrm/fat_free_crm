require 'spec_helper'
require 'cancan/matchers'

def all_actions
  [:index, :show, :create, :update, :destroy, :manage]
end

describe "User abilities" do

  subject(:ability)  { Ability.new(user) }
  let(:subject_user) { create :user }

  context "when site manager, I" do
    let(:user)  { create :user, admin: true}
    all_actions.each do |do_action|
      it{ should be_able_to(do_action, subject_user) }
    end
  end

  context "when myself, I" do
    let(:user) { create :user }
    let(:subject_user) { user }
    all_actions.each do |do_action|
      it{ should be_able_to(do_action, subject_user) }
    end
  end

  context "when another user, I" do
    let(:user)  { create :user }
    let(:can)    { [] }
    let(:cannot) { [:show, :create, :update, :index, :destroy, :manage] }
    it{ can.each do |do_action|
      should be_able_to(do_action, subject_user)
    end}
    it{ cannot.each do |do_action|
      should_not be_able_to(do_action, subject_user)
    end}
  end

  context "when anonymous user, I" do
    let(:user)  { nil }
    let(:can)    { [] }
    let(:cannot) { [:show, :create, :update, :index, :destroy, :manage] }
    it{ can.each do |do_action|
      should be_able_to(do_action, subject_user)
    end}
    it{ cannot.each do |do_action|
      should_not be_able_to(do_action, subject_user)
    end}

    it "and signup enabled" do
      User.stub(:can_signup?).and_return(true)
      should be_able_to(:create, User)
    end

  end

end
