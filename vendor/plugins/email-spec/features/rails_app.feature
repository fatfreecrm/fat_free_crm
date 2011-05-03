Feature: Email Spec in Rails App

In order to prevent me from shipping a defective email_spec gem
As a email_spec dev
I want to verify that the example rails app runs all of it's features as expected

  Scenario: generators test
    Given the rails_root app is setup with the latest generators
    Then the rails_root app should have the email steps in place

  Scenario: regression test
    Given the rails_root app is setup with the latest email steps
    When I run "rake db:migrate RAILS_ENV=test" in the rails_root app
    And I run "cucumber features -q --no-color" in the rails_root app
    Then I should see the following summary report:
    """
    12 scenarios (5 failed, 7 passed)
    101 steps (5 failed, 1 skipped, 95 passed)
    """
