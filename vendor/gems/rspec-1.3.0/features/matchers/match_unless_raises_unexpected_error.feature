Feature: match unless raises with an unexpected error

  In order to know when a match_unless_raises block raises an unexpected error
  As an RSpec user
  I want the error to bubble up

  Background:
    Given a file named "example.rb" with:
      """
      Spec::Matchers.define :be_the_same_as do |expected|
        match_unless_raises SyntaxError do |actual|
          raise "unexpected error"
        end
      end
      """
  
  Scenario: failing examples
    Given a file named "match_unless_raises_spec.rb" with:
      """
      require 'example.rb'

      describe 4 do
        it "is 4" do
          # intentionally fail
          4.should_not be_the_same_as(4)
        end
      end

      describe 5 do
        it "is not 4" do
          # intentionally fail
          5.should be_the_same_as(4)
        end
      end
      """
    When I run "spec match_unless_raises_spec.rb"
    Then the stdout should include "2 examples, 2 failures"
    Then the stdout should include "unexpected error"
  