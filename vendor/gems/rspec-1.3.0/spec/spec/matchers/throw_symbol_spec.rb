require 'spec_helper'

module Spec
  module Matchers
    describe ThrowSymbol do
      describe "with no args" do
        let(:matcher) { ThrowSymbol.new }

        it "matches if any Symbol is thrown" do
          matcher.matches?(lambda{ throw :sym }).should be_true
        end

        it "matches if any Symbol is thrown with an arg" do
          matcher.matches?(lambda{ throw :sym, "argument" }).should be_true
        end

        it "does not match if no Symbol is thrown" do
          matcher.matches?(lambda{ }).should be_false
        end

        it "provides a failure message" do
          matcher.matches?(lambda{})
          matcher.failure_message_for_should.should == "expected a Symbol but nothing was thrown"
        end

        it "provides a negative failure message" do
          matcher.matches?(lambda{ throw :sym})
          matcher.failure_message_for_should_not.should == "expected no Symbol, got :sym"
        end
      end

      describe "with a symbol" do
        let(:matcher) { ThrowSymbol.new(:sym) }

        it "matches if correct Symbol is thrown" do
          matcher.matches?(lambda{ throw :sym }).should be_true
        end

        it "matches if correct Symbol is thrown with an arg" do
          matcher.matches?(lambda{ throw :sym, "argument" }).should be_true
        end

        it "does not match if no Symbol is thrown" do
          matcher.matches?(lambda{ }).should be_false
        end

        it "does not match if correct Symbol is thrown" do
          matcher.matches?(lambda{ throw :other_sym }).should be_false
        end

        it "provides a failure message when no Symbol is thrown" do
          matcher.matches?(lambda{})
          matcher.failure_message_for_should.should == "expected :sym but nothing was thrown"
        end

        it "provides a failure message when wrong Symbol is thrown" do
          matcher.matches?(lambda{ throw :other_sym })
          matcher.failure_message_for_should.should == "expected :sym, got :other_sym"
        end

        it "provides a negative failure message" do
          matcher.matches?(lambda{ throw :sym })
          matcher.failure_message_for_should_not.should == "expected :sym not to be thrown"
        end

        it "should only match NameErrors raised by uncaught throws" do
          matcher.matches?(lambda{ :sym }).should be_false
        end
        
        it "bubbles up errors other than NameError" do
          lambda do
            matcher.matches?(lambda{ raise 'foo' })
          end.should raise_error('foo')
        end
      end

      describe "with a symbol and an arg" do
        let(:matcher) { ThrowSymbol.new(:sym, "a") }

        it "matches if correct Symbol and args are thrown" do
          matcher.matches?(lambda{ throw :sym, "a" }).should be_true
        end

        it "does not match if nothing is thrown" do
          matcher.matches?(lambda{ }).should be_false
        end

        it "does not match if other Symbol is thrown" do
          matcher.matches?(lambda{ throw :other_sym, "a" }).should be_false
        end

        it "does not match if no arg is thrown" do
          matcher.matches?(lambda{ throw :sym }).should be_false
        end

        it "does not match if wrong arg is thrown" do
          matcher.matches?(lambda{ throw :sym, "b" }).should be_false
        end

        it "provides a failure message when no Symbol is thrown" do
          matcher.matches?(lambda{})
          matcher.failure_message_for_should.should == %q[expected :sym with "a" but nothing was thrown]
        end

        it "provides a failure message when wrong Symbol is thrown" do
          matcher.matches?(lambda{ throw :other_sym })
          matcher.failure_message_for_should.should == %q[expected :sym with "a", got :other_sym]
        end

        it "provides a negative failure message" do
          matcher.matches?(lambda{ throw :sym })
          matcher.failure_message_for_should_not.should == %q[expected :sym with "a" not to be thrown]
        end

        it "only matches NameErrors raised by uncaught throws" do
          matcher.matches?(lambda{ :sym }).should be_false
        end
      end
    end
  end
end
