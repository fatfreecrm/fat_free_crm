@javascript
Feature: Users can manage contacts
  In order to track contacts for fun and profit
  Users
  Want to be able to create and edit contacts

  Scenario: User can create a contact
    Given a logged in user
    When I go to the contacts page
    And I follow "Create Contact"
    And I fill in the following:
      | contact[first_name] | William |
      | contact[last_name]  | Billy   |
    And I press "Create Contact"
    Then I should see "William Billy"

  Scenario: User can edit a contact
    Given a logged in user
    And a contact with full name "Terrence van York"
    When I go to the contacts page
    Then I should see "Terrence van York"
    When I move the mouse over "contact_1"
    And I follow "Edit" within "#contact_1"
    And I fill in "contact[first_name]" with "Schwing a Lot"
    And I fill in "contact[last_name]" with "Lumbermanson"
    And I press "Save Contact"
    Then I should see "Schwing a Lot Lumbermanson"

