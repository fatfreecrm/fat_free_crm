# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe EntityObserver do

  before do
    Setting.stub(:host).and_return('http://www.example.com')
    PaperTrail.stub(:whodunnit).and_return(assigner)
  end

  [:account, :contact, :lead, :opportunity].each do |entity_type|
    describe "on creation of #{entity_type}" do
      let(:assignee) { create(:user) }
      let(:assigner) { create(:user) }
      let!(:entity)  { build(entity_type, user: assigner, assignee: assignee) }
      let(:mail) { double('mail', deliver: true) }

      after :each do
        entity.save
      end

      it "sends notification to the assigned user for entity" do
        UserMailer.should_receive(:assigned_entity_notification).with(entity, assigner).and_return(mail)
      end

      it "does not notify anyone if the entity is created and assigned to no-one" do
        entity.assignee = nil
        UserMailer.should_not_receive(:assigned_entity_notification)
      end

      it "does not notify me if I have created an entity for myself" do
        entity.assignee = entity.user = assigner
        UserMailer.should_not_receive(:assigned_entity_notification)
      end

      it "does not notify me if Setting.host has not been set" do
        Setting.stub(:host).and_return('')
        UserMailer.should_not_receive(:assigned_entity_notification)
      end

    end

    describe "on update of #{entity_type}" do
      let(:assignee) { create(:user) }
      let(:assigner) { create(:user) }
      let!(:entity)  { create(entity_type, user: create(:user)) }
      let(:mail) { double('mail', deliver: true) }

      it "notifies the new owner if the entity is re-assigned" do
        UserMailer.should_receive(:assigned_entity_notification).with(entity, assigner).and_return(mail)
        entity.update_attributes(assignee: assignee)
      end

      it "does not notify the owner if the entity is not re-assigned" do
        UserMailer.should_not_receive(:assigned_entity_notification)
        entity.touch
      end

      it "does not notify anyone if the entity becomes unassigned" do
        UserMailer.should_not_receive(:assigned_entity_notification)
        entity.update_attributes(assignee: nil)
      end

      it "does not notify me if I re-assign an entity to myself" do
        UserMailer.should_not_receive(:assigned_entity_notification)
        entity.update_attributes(assignee: assigner)
      end
    end

  end
end
