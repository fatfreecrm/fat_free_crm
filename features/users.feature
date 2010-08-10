Feature: Users can login and use the CRM
  In order to ensure only authorised users can access the CRM
  Users
  Want to be able to login and edit their profile

  Scenario: User can login
    Given a user with attributes:
      |username|bob|
    When I go to the home page
    Then I should see "Login"
    When I fill in the following:
      |authentication[username]|bob     |
      |authentication[password]|password|
    And I press "Login"
    Then I should see "Welcome to Fat Free CRM!"

  @javascript
  Scenario: User can edit their profile
    Given a logged in user
    When I go to the home page
    Then I should see "Profile"
    When I follow "Profile"
    Then I should see "My Profile"
    When I follow "Edit Profile"
    Then I should see "First name:"
    When I fill in the following:
      |user[first_name]|Bob     |
      |user[last_name] |Jones   |
    And I press "Save Profile"
    Then I should see "Bob Jones"
