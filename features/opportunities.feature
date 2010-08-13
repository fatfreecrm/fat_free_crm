@javascript
Feature: Users can manage opportunities
  In order to track opportunities for fun and profit
  Users
  Want to be able to create, edit, and workflow opportunities

  Scenario: User can create an opportunity
    Given a logged in user
    When I go to the opportunities page
    And I follow "Create Opportunity"
    And I fill in the following:
      |opportunity[name]|Sell boat|
      |account[name]    |Bob      |
    And I press "Create Opportunity"
    Then I should see "Sell boat"

  Scenario: User can edit an opportunity
    Given a logged in user
    And an opportunity named "Sell Boat" from "Bob"
    When I go to the opportunities page
    When I move the mouse over "opportunity_1"
    And I follow "Edit" within "#opportunity_1"
    And I fill in "opportunity[name]" with "Sell big boat"
    And I press "Save Opportunity"
    Then I should see "Sell big boat"
