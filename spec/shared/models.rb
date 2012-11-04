module SharedModelSpecs
  shared_examples_for "exportable" do
    it "Model#export returns all records with extra attributes added" do
      pending
      # User/assignee for the second record has no first/last name.
      exported.size.should == 2
      exported[0].user_id_full_name.should == "#{exported[0].user.first_name} #{exported[0].user.last_name}"
      exported[1].user_id_full_name.should == "#{exported[1].user.email}"

      if exported[0].respond_to?(:assigned_to)
        if exported[0].assigned_to?
          exported[0].assigned_to_full_name.should == "#{exported[0].assignee.first_name} #{exported[0].assignee.last_name}"
        else
          exported[0].assigned_to_full_name.should == ''
        end
        if exported[1].assigned_to?
          exported[1].assigned_to_full_name.should == "#{exported[1].assignee.email}"
        else
          exported[1].assigned_to_full_name.should == ''
        end
      end

      if exported[0].respond_to?(:completed_by)
        if exported[0].completed_by?
          exported[0].completed_by_full_name.should == "#{exported[0].completor.first_name} #{exported[0].completor.last_name}"
        else
          exported[0].completed_by_full_name.should == ''
        end
        if exported[1].completed_by?
          exported[1].completed_by_full_name.should == "#{exported[1].completor.email}"
        else
          exported[1].completed_by_full_name.should == ''
        end
      end
    end
  end

  require "cancan/matchers"

  shared_examples_for Ability do |klass|

    subject { ability }
    let(:ability){ Ability.new(user) }
    let(:user){ FactoryGirl.create(:user) }
    let(:factory){ klass.model_name.underscore }

    context "create" do
      it{ should be_able_to(:create, klass) }
    end

    context "when public access" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Public') }

      it{ should be_able_to(:manage, asset) }
    end

    context "when private access owner" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Private', :user_id => user.id) }

      it{ should be_able_to(:manage, asset) }
    end
    
    context "when private access administrator" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Private') }
      let(:user) { FactoryGirl.create(:user, :admin => true) }

      it{ should be_able_to(:manage, asset) }
    end

    context "when private access not owner" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Private') }

      it{ should_not be_able_to(:manage, asset) }
    end
    
    context "when private access not owner but is assigned" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Private', :assigned_to => user.id) }

      it{ should be_able_to(:manage, asset) }
    end

    context "when shared access with permission" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Shared', :permissions => [permission]) }
      let(:permission){ Permission.new(:user => user) }

      it{ should be_able_to(:manage, asset) }
    end

    context "when shared access with no permission" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Shared', :permissions => [permission]) }
      let(:permission){ Permission.new(:user => FactoryGirl.create(:user)) }

      it{ should_not be_able_to(:manage, asset) }
    end
    
    context "when shared access with no permission but administrator" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Shared', :permissions => [permission]) }
      let(:permission){ Permission.new(:user => FactoryGirl.create(:user)) }
      let(:user) { FactoryGirl.create(:user, :admin => true) }

      it{ should be_able_to(:manage, asset) }
    end
    
    context "when shared access with no permission but assigned" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Shared', :permissions => [permission], :assigned_to => user.id) }
      let(:permission){ Permission.new(:user => FactoryGirl.create(:user)) }

      it{ should be_able_to(:manage, asset) }
    end

    context "when shared access with group permission" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Shared', :permissions => [permission]) }
      let(:permission){ Permission.new(:group => group) }
      let(:group){ FactoryGirl.create(:group, :users => [user]) }

      it{ should be_able_to(:manage, asset) }
    end
    
    context "when shared access with several group permissions" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Shared', :permissions => permissions) }
      let(:permissions){ [Permission.new(:group => group1), Permission.new(:group => group2)] }
      let(:group1){ FactoryGirl.create(:group, :users => [user]) }
      let(:group2){ FactoryGirl.create(:group, :users => [user]) }

      it{ should be_able_to(:manage, asset) }
    end

    context "when shared access with no group permission" do
      let(:asset){ FactoryGirl.create(factory, :access => 'Shared', :permissions => [permission]) }
      let(:permission){ Permission.new(:group => group) }
      let(:group){ FactoryGirl.create(:group) }

      it{ should_not be_able_to(:manage, asset) }
    end
    
  end
end
