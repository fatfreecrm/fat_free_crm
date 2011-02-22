Feature: block local expectations

  In order to set message expectations on ...
  As an RSpec user
  I want to configure the evaluation context

  Background:
    Given a file named "account.rb" with:
      """
      class Account
        def self.create
          yield new
        end

        def opening_balance(amount, currency)
        end
      end
      """

  Scenario: passing example
    Given a file named "account_dsl.rb" with:
      """
      require 'spec_helper'
      require 'account'

      describe "account DSL" do
        it " .... " do
          account = Account.new
          Account.should_receive(:create).and_yield do |account|
            account.should_receive(:opening_balance).with(100, :USD)
          end
          Account.create do
            opening_balance 100, :USD
          end
        end
      end
      """
    When I run "spec account_dsl.rb"
    Then the stdout should include "1 example, 0 failures"
    
  Scenario: failing example
    
    Given a file named "account_dsl.rb" with:
      """
      require 'spec_helper'
      require 'account'

      describe "account DSL" do
        it " .... " do
          account = Account.new
          Account.should_receive(:create).and_yield do |account|
            account.should_receive(:opening_balance).with(100, :USD)
          end
          Account.create do
            # opening_balance is not called here
          end
        end
      end
      """

    When I run "spec account_dsl.rb"
    Then the stdout should include "1 example, 1 failure"
