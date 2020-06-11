require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module FatFreeCrm
  describe Contact do
    describe "requirements" do
      it "should save with required attributes" do
        expect(Contact.new(first_name: "Denzel", last_name: "Washington").valid?).to eq(true)
      end
    end

    describe "attributes" do
      let(:new_contact) { Contact.new }
      it "should respond to the proper has_many classes" do
        have_many_classes = [:contact_opportunities, :opportunities, :tasks, :identifiers, :assignments, :absences, :exposures, :emails]
        have_many_classes.each do |model_name_pluralized|
          expect(new_contact.respond_to?(model_name_pluralized)).to eq(true)
        end
      end

      it "should respond to the proper belongs_to classes" do
        belongs_to_classes = [:user, :lead, :assignee, :reporting_user]
        belongs_to_classes.each do |model_name|
          expect(new_contact.respond_to?(model_name)).to eq(true)
        end
      end
    end
  end
end
