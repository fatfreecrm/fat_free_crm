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
#  email               :string(64)      default(""), not null
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
#  password_hash       :string(255)     default(""), not null
#  password_salt       :string(255)     default(""), not null
#  persistence_token   :string(255)     default(""), not null
#  perishable_token    :string(255)     default(""), not null
#  last_login_at       :datetime
#  current_login_at    :datetime
#  last_login_ip       :string(255)
#  current_login_ip    :string(255)
#  login_count         :integer         default(0), not null
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  admin               :boolean         default(FALSE), not null
#  suspended_at        :datetime
#  single_access_token :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe User do
  it "should create a new instance given valid attributes" do
    User.create!(
      username: "username",
      email:    "user@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  it "should have a valid factory" do
    expect(FactoryGirl.build(:user)).to be_valid
  end

  describe "Destroying users with and without related assets" do
    before do
      @user = FactoryGirl.create(:user)
    end

    %w(account campaign lead contact opportunity).each do |asset|
      it "should not destroy the user if she owns #{asset}" do
        FactoryGirl.create(asset, user: @user)
        @user.destroy
        expect { User.find(@user.id) }.to_not raise_error
        expect(@user.destroyed?).to eq(false)
      end

      it "should not destroy the user if she has #{asset} assigned" do
        FactoryGirl.create(asset, assignee: @user)
        @user.destroy
        expect { User.find(@user.id) }.to_not raise_error
        expect(@user.destroyed?).to eq(false)
      end
    end

    it "should not destroy the user if she owns a comment" do
      login
      account = FactoryGirl.create(:account, user: current_user)
      FactoryGirl.create(:comment, user: @user, commentable: account)
      @user.destroy
      expect { User.find(@user.id) }.to_not raise_error
      expect(@user.destroyed?).to eq(false)
    end

    it "should not destroy the current user" do
      login
      current_user.destroy
      expect { current_user.reload }.to_not raise_error
      expect(current_user).not_to be_destroyed
    end

    it "should destroy the user" do
      @user.destroy
      expect { User.find(@user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(@user).to be_destroyed
    end

    it "once the user gets deleted all her permissions must be deleted too" do
      FactoryGirl.create(:permission, user: @user, asset: FactoryGirl.create(:account))
      FactoryGirl.create(:permission, user: @user, asset: FactoryGirl.create(:contact))
      expect(@user.permissions.count).to eq(2)
      @user.destroy
      expect(@user.permissions.count).to eq(0)
    end

    it "once the user gets deleted all her preferences must be deleted too" do
      FactoryGirl.create(:preference, user: @user, name: "Hello", value: "World")
      FactoryGirl.create(:preference, user: @user, name: "World", value: "Hello")
      expect(@user.preferences.count).to eq(2)
      @user.destroy
      expect(@user.preferences.count).to eq(0)
    end
  end

  it "should set suspended timestamp upon creation if signups need approval and the user is not an admin" do
    allow(Setting).to receive(:user_signup).and_return(:needs_approval)
    @user = FactoryGirl.create(:user, suspended_at: nil)
    expect(@user).to be_suspended
  end

  it "should not set suspended timestamp upon creation if signups need approval and the user is an admin" do
    allow(Setting).to receive(:user_signup).and_return(:needs_approval)
    @user = FactoryGirl.create(:user, admin: true, suspended_at: nil)
    expect(@user).not_to be_suspended
  end

  context "scopes" do
    describe "have_assigned_opportunities" do
      before :each do
        @user1 = FactoryGirl.create(:user)
        FactoryGirl.create(:opportunity, assignee: @user1, stage: 'analysis')

        @user2 = FactoryGirl.create(:user)

        @user3 = FactoryGirl.create(:user)
        FactoryGirl.create(:opportunity, assignee: @user3, stage: 'won')

        @user4 = FactoryGirl.create(:user)
        FactoryGirl.create(:opportunity, assignee: @user4, stage: 'lost')
      end

      it "includes users with assigned opportunities" do
        expect(User.have_assigned_opportunities).to include(@user1)
      end

      it "excludes users without any assigned opportunities" do
        expect(User.have_assigned_opportunities).not_to include(@user2)
      end

      it "excludes users with opportunities that have been won or lost" do
        expect(User.have_assigned_opportunities).not_to include(@user3)
        expect(User.have_assigned_opportunities).not_to include(@user4)
      end
    end
  end

  context "instance methods" do
    describe "assigned_opportunities" do
      before :each do
        @user = FactoryGirl.create(:user)
        @opportunity1 = FactoryGirl.create(:opportunity, assignee: @user)
        @opportunity2 = FactoryGirl.create(:opportunity, assignee: FactoryGirl.create(:user))
      end

      it "includes opportunities assigned to user" do
        expect(@user.assigned_opportunities).to include(@opportunity1)
      end

      it "does not include opportunities assigned to another user" do
        expect(@user.assigned_opportunities).not_to include(@opportunity2)
      end
    end
  end

  describe "Setting I18n.locale" do
    before do
      @user = FactoryGirl.create(:user)
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

  describe "Setting single access token" do
    it "should update single_access_token attribute if it is not set already" do
      @user = FactoryGirl.create(:user, single_access_token: nil)

      @user.set_single_access_token
      expect(@user.single_access_token).not_to eq(nil)
    end

    it "should not update single_access_token attribute if it is set already" do
      @user = FactoryGirl.create(:user, single_access_token: "token")

      @user.set_single_access_token
      expect(@user.single_access_token).to eq("token")
    end
  end

  describe "serialization" do
    let(:user) { FactoryGirl.build(:user) }

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
