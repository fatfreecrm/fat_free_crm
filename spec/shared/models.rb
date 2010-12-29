module SharedModelSpecs
  shared_examples_for "exportable" do
    it "Model#export returns all records with extra attributes added" do
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
end