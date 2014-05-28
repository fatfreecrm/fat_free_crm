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
#  last_sign_in_at     :datetime
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

require 'spec_helper'

describe User do
  it "should create a new instance given valid attributes" do
    User.create!(
      username: "username",
      email: "user@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  describe "Destroying users with and without related assets" do
    let(:current_user) { create :user }

    before do
      @user = create(:user)
    end

    %w(account campaign lead contact opportunity).each do |asset|
      it "should not destroy the user if she owns #{asset}" do
        create(asset, user: @user)
        @user.destroy
        expect { User.find(@user) }.to_not raise_error()
        @user.destroyed?.should == false
      end

      it "should not destroy the user if she has #{asset} assigned" do
        create(asset, assignee: @user)
        @user.destroy
        expect { User.find(@user) }.to_not raise_error()
        @user.destroyed?.should == false
      end
    end

    it "should not destroy the user if she owns a comment" do
      account = create(:account, user: current_user)
      create(:comment, user: @user, commentable: account)
      @user.destroy
      expect { User.find(@user) }.to_not raise_error()
      @user.destroyed?.should == false
    end

    # it "should not destroy the current user" do
    #   current_user.destroy
    #   expect { current_user.reload }.to_not raise_error()
    #   current_user.should_not be_destroyed
    # end

    it "should destroy the user" do
      @user.destroy
      expect { User.find(@user) }.to raise_error(ActiveRecord::RecordNotFound)
      @user.should be_destroyed
    end

    it "once the user gets deleted all her permissions must be deleted too" do
      create(:permission, user: @user, asset: create(:account))
      create(:permission, user: @user, asset: create(:contact))
      @user.permissions.count.should == 2
      @user.destroy
      @user.permissions.count.should == 0
    end

    it "once the user gets deleted all her preferences must be deleted too" do
      create(:preference, user: @user, name: "Hello", value: "World")
      create(:preference, user: @user, name: "World", value: "Hello")
      @user.preferences.count.should == 2
      @user.destroy
      @user.preferences.count.should == 0
    end
  end

  it "should set suspended timestamp upon creation if signups need approval and the user is not an admin" do
    Setting.stub(:user_signup).and_return(:needs_approval)
    @user = create(:user, suspended_at: nil)
    @user.should be_suspended
  end

  it "should not set suspended timestamp upon creation if signups need approval and the user is an admin" do
    Setting.stub(:user_signup).and_return(:needs_approval)
    @user = create(:user, admin: true, suspended_at: nil)
    @user.should_not be_suspended
  end

  context "scopes" do
    describe "have_assigned_opportunities" do
      before :each do
        @user1 = create(:user)
        create(:opportunity, assignee: @user1, stage: 'analysis')

        @user2 = create(:user)

        @user3 = create(:user)
        create(:opportunity, assignee: @user3, stage: 'won')

        @user4 = create(:user)
        create(:opportunity, assignee: @user4, stage: 'lost')
      end

      it "includes users with assigned opportunities" do
        User.have_assigned_opportunities.should include(@user1)
      end

      it "excludes users without any assigned opportunities" do
        User.have_assigned_opportunities.should_not include(@user2)
      end

      it "excludes users with opportunities that have been won or lost" do
        User.have_assigned_opportunities.should_not include(@user3)
        User.have_assigned_opportunities.should_not include(@user4)
      end
    end
  end

  context "instance methods" do
    describe "assigned_opportunities" do
      before :each do
        @user = create(:user)
        @opportunity1 = create(:opportunity, assignee: @user)
        @opportunity2 = create(:opportunity, assignee: create(:user))
      end

      it "includes opportunities assigned to user" do
        @user.assigned_opportunities.should include(@opportunity1)
      end

      it "does not include opportunities assigned to another user" do
        @user.assigned_opportunities.should_not include(@opportunity2)
      end
    end
  end

  describe "Setting I18n.locale" do
    before do
      @user = create(:user)
      @locale = I18n.locale
    end

    after do
      I18n.locale = @locale
    end

    it "should update I18n.locale if proference[:locale] is set" do
      @user.preference[:locale] = :es
      @user.set_individual_locale
      I18n.locale.should == :es
    end

    it "should not update I18n.locale if proference[:locale] is not set" do
      @user.preference[:locale] = nil
      @user.set_individual_locale
      I18n.locale.should == @locale
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
end
