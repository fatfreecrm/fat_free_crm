require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module FatFreeCrm
  describe IndexCase do
    let!(:user) { create(:user) }
    let(:new_index_case) { IndexCase.new(user_id: user.id) }

    describe "requirements" do
      it "should save with required attributes" do
        expect(IndexCase.new.valid?).to eq(true)
      end
    end

    describe "attributes" do
      let(:new_index_case) { IndexCase.new }
      it "should respond to the proper has_many classes" do
        have_many_classes = [:tasks, :investigations, :exposures, :emails]
        have_many_classes.each do |model_name_pluralized|
          expect(new_index_case.respond_to?(model_name_pluralized)).to eq(true)
        end
      end

      it "should respond to the proper belongs_to classes" do
        belongs_to_classes = [:user, :contact, :assignee, :opportunity]
        belongs_to_classes.each do |model_name|
          expect(new_index_case.respond_to?(model_name)).to eq(true)
        end
      end
    end
  end
end
