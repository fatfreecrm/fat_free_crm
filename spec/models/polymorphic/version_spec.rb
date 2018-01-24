# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: versions
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  item_id   :integer
#  item_type :string(255)
#  event       :string(32)      default("create")
#  info         :string(255)     default("")
#  private      :boolean         default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Version, versioning: true do
  let(:current_user) { create(:user) }
  before { PaperTrail.whodunnit = current_user.id.to_s }

  it "should create a new instance given valid attributes" do
    create(:version, whodunnit: PaperTrail.whodunnit, item: create(:lead))
  end

  describe "with multiple version records" do
    before do
      @lead = create(:lead)

      %w[create destroy update view].each do |event|
        create(:version, event: event, item: @lead, whodunnit: PaperTrail.whodunnit)
        create(:version, event: event, item: @lead, whodunnit: "1")
      end
    end

    it "should not include view events" do
      @versions = Version.for(current_user).exclude_events(:view)
      expect(@versions.pluck(:event).sort).not_to include('view')
    end

    it "should exclude create, update and destroy events" do
      @versions = Version.for(current_user).exclude_events(:create, :update, :destroy)
      expect(@versions.pluck(:event)).not_to include('create')
      expect(@versions.pluck(:event)).not_to include('update')
      expect(@versions.pluck(:event)).not_to include('destroy')
    end

    it "should include only destroy events" do
      @versions = Version.for(current_user).include_events(:destroy)
      expect(@versions.pluck(:event).uniq).to eq(['destroy'])
    end

    it "should include create and update events" do
      @versions = Version.for(current_user).include_events(:create, :update)
      expect(@versions.pluck(:event).uniq.sort).to eq(%w[create update])
    end

    it "should select all versions for a given user" do
      @versions = Version.for(current_user)
      expect(@versions.map(&:whodunnit).uniq).to eq([current_user.id.to_s])
    end
  end

  %w[account campaign contact lead opportunity task].each do |item|
    describe "Create, update, and delete (#{item})" do
      before :each do
        @item = create(item.to_sym, user: current_user)
        @conditions = { item_id: @item.id, item_type: @item.class.name, whodunnit: PaperTrail.whodunnit }
      end

      it "should add a version when creating new #{item}" do
        @version = Version.where(@conditions.merge(event: 'create')).first
        expect(@version).not_to eq(nil)
      end

      it "should add a version when updating existing #{item}" do
        if @item.respond_to?(:full_name)
          @item.update_attributes(first_name: "Billy", last_name: "Bones")
        else
          @item.update_attributes(name: "Billy Bones")
        end
        @version = Version.where(@conditions.merge(event: 'update')).first

        expect(@version).not_to eq(nil)
      end

      it "should add a version when deleting #{item}" do
        @item.destroy
        @version = Version.where(@conditions.merge(event: 'destroy')).first

        expect(@version).not_to eq(nil)
      end

      it "should add a version when commenting on a #{item}" do
        @comment = create(:comment, commentable: @item, user: current_user)

        @version = Version.where(related_id: @item.id, related_type: @item.class.name, whodunnit: PaperTrail.whodunnit, event: 'create').first
        expect(@version).not_to eq(nil)
      end
    end
  end

  describe "Recently viewed items (task)" do
    before do
      @task = create(:task)
      @conditions = { item_id: @task.id, item_type: @task.class.name }
    end

    it "creating a new task should not add it to recently viewed items list" do
      versions = Version.where(@conditions)
      expect(versions.pluck(:event)).to include('create') # but not view
    end

    it "updating a new task should not add it to recently viewed items list" do
      @task.update(name: 'New Name')

      versions = Version.where(@conditions)
      expect(versions.pluck(:event).sort).to eq(%w[create update]) # but not view
    end
  end

  describe "Action refinements for task updates" do
    before do
      @task = create(:task, user: current_user)
      @conditions = { item_id: @task.id, item_type: @task.class.name, whodunnit: PaperTrail.whodunnit }
    end

    it "should create 'completed' task event" do
      @task.update(completed_at: 1.second.ago)

      versions = Version.where(@conditions)
      expect(versions.pluck(:event)).to include('complete')
    end

    it "should create 'reassigned' task event" do
      @task.update(assigned_to: current_user.id + 1)

      versions = Version.where(@conditions)
      expect(versions.pluck(:event)).to include('reassign')
    end

    it "should create 'rescheduled' task event" do
      @task.update(bucket: "due_tomorrow") # FactoryBot creates :due_asap task

      versions = Version.where(@conditions)
      expect(versions.pluck(:event)).to include('reschedule')
    end
  end

  describe "Rejecting a lead" do
    before do
      @lead = create(:lead, user: current_user, status: "new")
      @conditions = { item_id: @lead.id, item_type: @lead.class.name, whodunnit: PaperTrail.whodunnit }
    end

    it "should create 'rejected' lead event" do
      @lead.update(status: "rejected")

      versions = Version.where(@conditions)
      expect(versions.pluck(:event)).to include('reject')
    end
  end

  describe "Permissions" do
    before do
      @user = create(:user)
      Version.delete_all
    end

    it "should not show the create/update versions if the item is private" do
      @item = create(:account, user: current_user, access: "Private")
      @item.update(name: 'New Name')

      versions = Version.where(item_id: @item.id, item_type: @item.class.name)
      expect(versions.pluck(:event).sort).to eq(%w[create update])

      visible_versions = Version.visible_to(@user)
      expect(visible_versions).to eq([])
    end

    it "should not show the destroy version if the item is private" do
      @item = create(:account, user: current_user, access: "Private")
      @item.destroy

      versions = Version.where(item_id: @item.id, item_type: @item.class.name)
      expect(versions.pluck(:event).sort).to eq(%w[create destroy])

      visible_versions = Version.visible_to(@user)
      expect(visible_versions).to eq([])
    end

    it "should not show create/update versions if the item was not shared with the user" do
      @item = create(:account,
                     user: current_user,
                     access: "Shared",
                     permissions: [build(:permission, user: current_user, asset: @item)])
      @item.update(name: 'New Name')

      versions = Version.where(item_id: @item.id, item_type: @item.class.name)
      expect(versions.pluck(:event).sort).to eq(%w[create update])

      visible_versions = Version.visible_to(@user)
      expect(visible_versions).to eq([])
    end

    it "should not show the destroy version if the item was not shared with the user" do
      @item = create(:account,
                     user: current_user,
                     access: "Shared",
                     permissions: [build(:permission, user: current_user, asset: @item)])
      @item.destroy

      versions = Version.where(item_id: @item.id, item_type: @item.class.name)
      expect(versions.pluck(:event).sort).to eq(%w[create destroy])

      visible_versions = Version.visible_to(@user)
      expect(visible_versions).to eq([])
    end

    it "should show create/update versions if the item was shared with the user" do
      @item = create(:account,
                     user: current_user,
                     access: "Shared",
                     permissions: [build(:permission, user: @user, asset: @item)])
      @item.update(name: 'New Name')

      versions = Version.where(item_id: @item.id, item_type: @item.class.name)
      expect(versions.pluck(:event).sort).to eq(%w[create update])

      visible_versions = Version.visible_to(@user)
      expect(visible_versions.map(&:event).sort).to eq(%w[create update])
    end
  end
end
