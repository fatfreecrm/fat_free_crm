Feature: conditional exclusion of example groups
  
  Example groups can be excluded from a run by matching the value of the
  --exclude argument against options passed to an example group. The value
  can be a key or a key:value pair (separated by a ":").
  
  Scenario: exclusion using explicit value
    Given the following spec:
      """
      describe "This should run" do
        it { 5.should == 5 }
      end
      
      describe "This should not run", :slow => true do
        it { 1_000_000.times { 5.should == 5 } }
      end
      """
    When I run it with the spec command --format specdoc --exclude slow:true
    Then the exit code should be 0
    And the stdout should match "1 example, 0 failures"
    And the stdout should match /This should run$/m
    But the stdout should not match "This should not run"

  Scenario: exclusion using default value (true)
    Given the following spec:
      """
      describe "This should run" do
        it { 5.should == 5 }
      end

      describe "This should not run", :slow => true do
        it { 1_000_000.times { 5.should == 5 } }
      end
      """
    When I run it with the spec command --format specdoc --exclude slow
    Then the exit code should be 0
    And the stdout should match "1 example, 0 failures"
    And the stdout should match /This should run$/m
    But the stdout should not match "This should not run"
