# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require "cancan/matchers"

shared_examples_for "exportable" do
  it "Model#export returns all records with extra attributes added" do
    # User/assignee for the second record has no first/last name.
    expect(exported.size).to eq(2)
    if exported[0].respond_to?(:user_id)
      expect(exported[0].user_id_full_name).to eq(exported[0].user.full_name)
      expect(exported[1].user_id_full_name).to eq(exported[1].user.email)
    end

    if exported[0].respond_to?(:assigned_to)
      if exported[0].assigned_to?
        expect(exported[0].assigned_to_full_name).to eq(exported[0].assignee.full_name)
      else
        expect(exported[0].assigned_to_full_name).to eq('')
      end
      if exported[1].assigned_to?
        expect(exported[1].assigned_to_full_name).to eq(exported[1].assignee.email)
      else
        expect(exported[1].assigned_to_full_name).to eq('')
      end
    end

    if exported[0].respond_to?(:completed_by)
      if exported[0].completed_by?
        expect(exported[0].completed_by_full_name).to eq(exported[0].completor.full_name)
      else
        expect(exported[0].completed_by_full_name).to eq('')
      end
      if exported[1].completed_by?
        expect(exported[1].completed_by_full_name).to eq(exported[1].completor.email)
      else
        expect(exported[1].completed_by_full_name).to eq('')
      end
    end
  end
end

shared_examples Ability do |klass|
  subject { ability }
  let(:ability) { Ability.new(user) }
  let(:user) { create(:user) }
  let(:factory) { klass.model_name.to_s.underscore }

  context "create" do
    it { is_expected.to be_able_to(:create, klass) }
  end

  context "when public access" do
    let!(:asset) { create(factory, access: 'Public') }

    it { is_expected.to be_able_to(:manage, asset) }
  end

  context "when private access owner" do
    let!(:asset) { create(factory, access: 'Private', user_id: user.id) }

    it { is_expected.to be_able_to(:manage, asset) }
  end

  context "when private access administrator" do
    let!(:asset) { create(factory, access: 'Private') }
    let(:user) { create(:user, admin: true) }

    it { is_expected.to be_able_to(:manage, asset) }
  end

  context "when private access not owner" do
    let!(:asset) { create(factory, access: 'Private') }

    it { is_expected.not_to be_able_to(:manage, asset) }
  end

  context "when private access not owner but is assigned" do
    let!(:asset) { create(factory, access: 'Private', assigned_to: user.id) }

    it { is_expected.to be_able_to(:manage, asset) }
  end

  context "when shared access with permission" do
    let!(:asset) { create(factory, access: 'Shared', permissions: [permission]) }
    let(:permission) { Permission.new(user: user) }

    it { is_expected.to be_able_to(:manage, asset) }
  end

  context "when shared access with no permission" do
    let!(:asset) { create(factory, access: 'Shared', permissions: [permission]) }
    let(:permission) { Permission.new(user: create(:user)) }

    it { is_expected.not_to be_able_to(:manage, asset) }
  end

  context "when shared access with no permission but administrator" do
    let!(:asset) { create(factory, access: 'Shared', permissions: [permission]) }
    let(:permission) { Permission.new(user: create(:user)) }
    let(:user) { create(:user, admin: true) }

    it { is_expected.to be_able_to(:manage, asset) }
  end

  context "when shared access with no permission but assigned" do
    let!(:asset) { create(factory, access: 'Shared', permissions: [permission], assigned_to: user.id) }
    let(:permission) { Permission.new(user: create(:user)) }

    it { is_expected.to be_able_to(:manage, asset) }
  end

  context "when shared access with group permission" do
    let!(:asset) { create(factory, access: 'Shared', permissions: [permission]) }
    let(:permission) { Permission.new(group: group) }
    let(:group) { create(:group, users: [user]) }

    it { is_expected.to be_able_to(:manage, asset) }
  end

  context "when shared access with several group permissions" do
    let!(:asset) { create(factory, access: 'Shared', permissions: permissions) }
    let(:permissions) { [Permission.new(group: group1), Permission.new(group: group2)] }
    let(:group1) { create(:group, users: [user]) }
    let(:group2) { create(:group, users: [user]) }

    it { is_expected.to be_able_to(:manage, asset) }
  end

  context "when shared access with no group permission" do
    let!(:asset) { create(factory, access: 'Shared', permissions: [permission]) }
    let(:permission) { Permission.new(group: group) }
    let(:group) { create(:group) }

    it { is_expected.not_to be_able_to(:manage, asset) }
  end
end
