# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: users
#
#  id                  :integer         not null, primary key
#  username            :string(32)      default(""), not null
#  email               :string(254)     default(""), not null
#  first_name          :string(32)
#  last_name           :string(32)
#  title               :string(64)
#  company             :string(64)
#  alt_email           :string(64)
#  phone               :string(32)
#  mobile              :string(32)
#  aim                 :string(32)
#  yahoo               :string(32)
#  google              :string(32)
#  skype               :string(32)
#  encrypted_password  :string(255)     default(""), not null
#  password_salt       :string(255)     default(""), not null
#  last_sign_in_at     :datetime
#  current_sign_in_at  :datetime
#  last_sign_in_ip     :string(255)
#  current_sign_in_ip  :string(255)
#  sign_in_count       :integer         default(0), not null
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  admin               :boolean         default(FALSE), not null
#  suspended_at        :datetime
#  unconfirmed_email   :string(254)     default(""), not null
#  reset_password_token    :string(255)
#  reset_password_sent_at  :datetime
#  remember_token          :string(255)
#  remember_created_at     :datetime
#  authentication_token    :string(255)
#  confirmation_token      :string(255)
#  confirmed_at            :datetime
#  confirmation_sent_at    :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe User do
  it "should create a new instance given valid attributes" do
    expect(User.new(
      username: "username",
      email:    "user@example.com",
      password: "password",
      password_confirmation: "password"
    ).valid?).to eq true
  end

  it "should have a valid factory" do
    expect(build(:user)).to be_valid
  end

  describe '#destroyable?' do
    describe "Destroying users with and without related assets" do
      before do
        @user = build(:user)
        @current_user = build(:user)
      end

      %w[account campaign lead contact opportunity].each do |asset|
        it "should not destroy the user if she owns #{asset}" do
          create(asset, user: @user)
          expect(@user.destroyable?(@current_user)).to eq(false)
        end

        it "should not destroy the user if she has #{asset} assigned" do
          create(asset, assignee: @user)
          expect(@user.destroyable?(@current_user)).to eq(false)
        end
      end

      it "should not destroy the user if she owns a comment" do
        account = build(:account, user: @current_user)
        FactoryBot.create(:comment, user: @user, commentable: account)
        expect(@user.destroyable?(@current_user)).to eq(false)
      end

      it "should not destroy the current user" do
        expect(@user.destroyable?(@user)).to eq(false)
      end

      it "should destroy the user" do
        expect(@user.destroyable?(@current_user)).to eq(true)
      end
    end
  end

  describe '#destroy' do
    before do
      @user = create(:user)
    end
    it "once the user gets deleted all her permissions must be deleted too" do
      create(:permission, user: @user, asset: create(:account))
      create(:permission, user: @user, asset: create(:contact))
      expect(@user.permissions.count).to eq(2)
      @user.destroy
      expect(@user.permissions.count).to eq(0)
    end

    it "once the user gets deleted all her preferences must be deleted too" do
      create(:preference, user: @user, name: "Hello", value: "World")
      create(:preference, user: @user, name: "World", value: "Hello")
      expect(@user.preferences.count).to eq(2)
      @user.destroy
      expect(@user.preferences.count).to eq(0)
    end
  end

  describe '#suspend_if_needs_approval' do
    it "should set suspended timestamp upon creation if signups need approval and the user is not an admin" do
      allow(Setting).to receive(:user_signup).and_return(:needs_approval)
      @user = build(:user, suspended_at: nil)

      @user.suspend_if_needs_approval

      expect(@user).to be_suspended
    end

    it "should not set suspended timestamp upon creation if signups need approval and the user is an admin" do
      allow(Setting).to receive(:user_signup).and_return(:needs_approval)
      @user = build(:user, admin: true, suspended_at: nil)

      @user.suspend_if_needs_approval

      expect(@user).not_to be_suspended
    end
  end

  context "scopes" do
    describe "have_assigned_opportunities" do
      before do
        @user1 = create(:user)
        create(:opportunity, assignee: @user1, stage: 'analysis', account: nil, campaign: nil, user: nil)

        @user2 = create(:user)

        @user3 = create(:user)
        create(:opportunity, assignee: @user3, stage: 'won', account: nil, campaign: nil, user: nil)

        @user4 = create(:user)
        create(:opportunity, assignee: @user4, stage: 'lost', account: nil, campaign: nil, user: nil)

        @result = User.have_assigned_opportunities
      end

      it "includes users with assigned opportunities" do
        expect(@result).to include(@user1)
      end

      it "excludes users without any assigned opportunities" do
        expect(@result).not_to include(@user2)
      end

      it "excludes users with opportunities that have been won or lost" do
        expect(@result).not_to include(@user3)
        expect(@result).not_to include(@user4)
      end
    end
  end

  context "instance methods" do
    describe "assigned_opportunities" do
      before do
        @user = create(:user)

        @opportunity1 = create(:opportunity, assignee: @user, account: nil, campaign: nil, user: nil)
        @opportunity2 = create(:opportunity, assignee: create(:user), account: nil, campaign: nil, user: nil)

        @result = @user.assigned_opportunities
      end

      it "includes opportunities assigned to user" do
        expect(@result).to include(@opportunity1)
      end

      it "does not include opportunities assigned to another user" do
        expect(@result).not_to include(@opportunity2)
      end
    end
  end

  describe "Setting I18n.locale" do
    before do
      @user = build(:user)
      @locale = I18n.locale
    end

    after do
      I18n.locale = @locale
    end

    it "should update I18n.locale if proference[:locale] is set" do
      @user.preference[:locale] = :es
      @user.set_individual_locale
      expect(I18n.locale).to eq(:es)
    end

    it "should not update I18n.locale if proference[:locale] is not set" do
      @user.preference[:locale] = nil
      @user.set_individual_locale
      expect(I18n.locale).to eq(@locale)
    end
  end

  describe "serialization" do
    let(:user) { build(:user) }

    it "to json" do
      expect(user.to_json).to eql([user.name].to_json)
    end

    it "to xml" do
      expect(user.to_xml).to eql([user.name].to_xml)
    end
  end

  describe "text_search" do
    it "should find user by email" do
      create(:user, email: 'no-reply@example.com')
      user = create(:user, email: 'test@example.com')
      search = User.text_search('test')
      expect(search.size).to eql(1)
      expect(search.first).to eql(user)
    end
  end
end
