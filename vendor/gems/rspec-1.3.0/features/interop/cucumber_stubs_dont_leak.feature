Feature: Cucumber Stubs Don't Leak
  In order to not explode from frustration
  a developer
  does not want rspec stubs to leak between cucumber scenarios

  Scenario: Create a stub
    When I stub "nap" on "Time" to "When I Get Cranky"
    Then calling "nap" on "Time" should return "When I Get Cranky"

  Scenario: Check to see if the stub leaked
    Then "nap" should not be defined on "Time"
