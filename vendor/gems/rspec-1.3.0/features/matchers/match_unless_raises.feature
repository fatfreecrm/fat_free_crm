Feature: match unless raises

  In order, primarily, to reuse existing test/unit assertions
  As an RSpec user
  I want to define matchers that wrap a statement that raises an error on failure

  Background:
    Given a file named "example.rb" with:
      """
      require 'test/unit/assertions'

      Spec::Matchers.define :be_the_same_as do |expected|
        extend Test::Unit::Assertions
        match_unless_raises Test::Unit::AssertionFailedError do |actual|
          assert_equal expected, actual
        end
      end
      """
  
  Scenario: passing examples
    Given a file named "match_unless_raises_spec.rb" with:
      """
      require 'example.rb'

      describe 4 do
        it "is 4" do
          4.should be_the_same_as(4)
        end
      end

      describe 5 do
        it "is not 4" do
          5.should_not be_the_same_as(4)
        end
      end
      """
    When I run "spec match_unless_raises_spec.rb"
    Then the stdout should include "2 examples, 0 failures"

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
