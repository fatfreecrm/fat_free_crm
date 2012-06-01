require 'spec_helper'

describe EntityObserver do
  [:account, :contact, :lead, :opportunity].each do |entity_type|
    describe "on creation of #{entity_type}" do
      let(:assignee) { FactoryGirl.create(:user) }
      let(:assigner) { FactoryGirl.create(:user) }
      let!(:entity)  { FactoryGirl.build(entity_type, :user => assigner, :assignee => assignee) }

      before :each do
        PaperTrail.stub(:whodunnit).and_return(assigner)
      end

      after :each do
        entity.save
      end

      it "sends notification to the assigned user for entity" do
        UserMailer.should_receive(:assigned_entity_notification).with(entity, assigner)
      end

      it "does not notify anyone if the entity is created and assigned to no-one" do
        entity.assignee = nil
        UserMailer.should_not_receive(:assigned_entity_notification)
      end

      it "does not notify me if I have created an entity for myself" do
        entity.assignee = entity.user = assigner
        UserMailer.should_not_receive(:assigned_entity_notification)
      end
    end

    describe "on update of #{entity_type}" do
      let(:assignee) { FactoryGirl.create(:user) }
      let(:assigner) { FactoryGirl.create(:user) }
      let!(:entity)  { FactoryGirl.create(entity_type, :user => FactoryGirl.create(:user)) }

      before :each do
        PaperTrail.stub(:whodunnit).and_return(assigner)
      end

      it "notifies the new owner if the entity is re-assigned" do
        UserMailer.should_receive(:assigned_entity_notification).with(entity, assigner)
        entity.update_attributes(:assignee => assignee)
      end

      it "does not notify the owner if the entity is not re-assigned" do
        UserMailer.should_not_receive(:assigned_entity_notification)
        entity.touch
      end

      it "does not notify anyone if the entity becomes unassigned" do
        UserMailer.should_not_receive(:assigned_entity_notification)
        entity.update_attributes(:assignee => nil)
      end

      it "does not notify me if I re-assign an entity to myself" do
        UserMailer.should_not_receive(:assigned_entity_notification)
        entity.update_attributes(:assignee => assigner)
      end
    end
  end
end
