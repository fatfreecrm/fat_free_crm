Feature: define matcher

  In order to express my domain clearly in my code examples
  As an RSpec user
  I want to define matchers with fluent interfaces
  
  Scenario: one additional method
    Given a file named "between_spec.rb" with:
      """
      Spec::Matchers.define :be_bigger_than do |first|
        def but_smaller_than(second)
          @second = second
          self
        end
        
        match do |actual|
          (actual > first) && (actual < @second)
        end
      end

      describe 5 do
        it { should be_bigger_than(4).but_smaller_than(6) }
      end
      """
    When I run "spec between_spec.rb --format specdoc"
    Then the stdout should include "1 example, 0 failures"
    And  the stdout should include "should be bigger than 4"

  Scenario: generate method using dsl
    Given a file named "between_spec.rb" with:
      """
      Spec::Matchers.define :be_bigger_than do |first|
        chain :but_smaller_than do |limit|
          @limit = limit
        end
        
        match do |actual|
          (actual > first) && (actual < @limit)
        end
      end

      describe 5 do
        it { should be_bigger_than(4).but_smaller_than(6) }
      end
      """
    When I run "spec between_spec.rb --format specdoc"
    Then the stdout should include "1 example, 0 failures"
    And  the stdout should include "should be bigger than 4"
