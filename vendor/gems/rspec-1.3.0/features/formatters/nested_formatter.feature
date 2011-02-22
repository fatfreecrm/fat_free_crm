Feature: nested formatter

  The nested formatter follows the nesting in each spec.

  Scenario: parallel contexts
    Given a file named "simple_example_spec.rb" with:
      """
      describe "first group" do
        context "with context" do
          specify "does something" do
          end
        end
      end
      describe "second group" do
        context "with context" do
          specify "does something" do
          end
        end
      end
      """

    When I run "spec simple_example_spec.rb --format nested"
    Then the exit code should be 0
    And the stdout should include
      """
      first group
        with context
          does something
      second group
        with context
          does something
      """
