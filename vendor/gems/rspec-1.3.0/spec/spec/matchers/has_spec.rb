require 'spec_helper'

describe "should have_sym(*args)" do
  it "should pass if #has_sym?(*args) returns true" do
    {:a => "A"}.should have_key(:a)
  end

  it "should fail if #has_sym?(*args) returns false" do
    lambda {
      {:b => "B"}.should have_key(:a)
    }.should fail_with("expected #has_key?(:a) to return true, got false")
  end

  it "should fail if #has_sym?(*args) returns nil" do
    klass = Class.new do
      def has_foo?
      end
    end
    lambda {
      klass.new.should have_foo
    }.should fail_with("expected #has_foo?(nil) to return true, got false")
  end

  it "should fail if target does not respond to #has_sym?" do
    lambda {
      Object.new.should have_key(:a)
    }.should raise_error(NoMethodError)
  end
  
  it "should reraise an exception thrown in #has_sym?(*args)" do
    o = Object.new
    def o.has_sym?(*args)
      raise "Funky exception"
    end
    lambda { o.should have_sym(:foo) }.should raise_error("Funky exception")
  end
end

describe "should_not have_sym(*args)" do
  it "should pass if #has_sym?(*args) returns false" do
    {:a => "A"}.should_not have_key(:b)
  end

  it "should pass if #has_sym?(*args) returns nil" do
    klass = Class.new do
      def has_foo?
      end
    end
    klass.new.should_not have_foo
  end

  it "should fail if #has_sym?(*args) returns true" do
    lambda {
      {:a => "A"}.should_not have_key(:a)
    }.should fail_with("expected #has_key?(:a) to return false, got true")
  end

  it "should fail if target does not respond to #has_sym?" do
    lambda {
      Object.new.should have_key(:a)
    }.should raise_error(NoMethodError)
  end
  
  it "should reraise an exception thrown in #has_sym?(*args)" do
    o = Object.new
    def o.has_sym?(*args)
      raise "Funky exception"
    end
    lambda { o.should_not have_sym(:foo) }.should raise_error("Funky exception")
  end
end

describe "should have_sym(&block)" do
  it "should pass when actual returns true for :has_sym?(&block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:has_foo?).and_yield
    delegate.should_receive(:check_has_foo).and_return(true)
    actual.should have_foo { delegate.check_has_foo }
  end

  it "should fail when actual returns false for :has_sym?(&block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:has_foo?).and_yield
    delegate.should_receive(:check_has_foo).and_return(false)
    lambda {
      actual.should have_foo { delegate.check_has_foo }
    }.should fail_with("expected #has_foo?(nil) to return true, got false")
  end

  it "should fail when actual does not respond to :has_sym?" do
    delegate = mock("delegate", :check_has_foo => true)
    lambda {
      Object.new.should have_foo { delegate.check_has_foo }
    }.should raise_error(NameError)
  end
end

describe "should_not have_sym(&block)" do
  it "should pass when actual returns false for :has_sym?(&block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:has_foo?).and_yield
    delegate.should_receive(:check_has_foo).and_return(false)
    actual.should_not have_foo { delegate.check_has_foo }
  end

  it "should fail when actual returns true for :has_sym?(&block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:has_foo?).and_yield
    delegate.should_receive(:check_has_foo).and_return(true)
    lambda {
      actual.should_not have_foo { delegate.check_has_foo }
    }.should fail_with("expected #has_foo?(nil) to return false, got true")
  end

  it "should fail when actual does not respond to :has_sym?" do
    delegate = mock("delegate", :check_has_foo => true)
    lambda {
      Object.new.should_not have_foo { delegate.check_has_foo }
    }.should raise_error(NameError)
  end
end

describe "should have_sym(*args, &block)" do
  it "should pass when actual returns true for :has_sym?(*args, &block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:has_foo?).with(:a).and_yield(:a)
    delegate.should_receive(:check_has_foo).with(:a).and_return(true)
    actual.should have_foo(:a) { |foo| delegate.check_has_foo(foo) }
  end

  it "should fail when actual returns false for :has_sym?(*args, &block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:has_foo?).with(:a).and_yield(:a)
    delegate.should_receive(:check_has_foo).with(:a).and_return(false)
    lambda {
      actual.should have_foo(:a) { |foo| delegate.check_has_foo(foo) }
    }.should fail_with("expected #has_foo?(:a) to return true, got false")
  end

  it "should fail when actual does not respond to :has_sym?" do
    delegate = mock("delegate", :check_has_foo => true)
    lambda {
      Object.new.should have_foo(:a) { |foo| delegate.check_has_foo(foo) }
    }.should raise_error(NameError)
  end
end

describe "should_not have_sym(*args, &block)" do
  it "should pass when actual returns false for :has_sym?(*args, &block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:has_foo?).with(:a).and_yield(:a)
    delegate.should_receive(:check_has_foo).with(:a).and_return(false)
    actual.should_not have_foo(:a) { |foo| delegate.check_has_foo(foo) }
  end

  it "should fail when actual returns true for :has_sym?(*args, &block)" do
    actual = mock("actual")
    delegate = mock("delegate")
    actual.should_receive(:has_foo?).with(:a).and_yield(:a)
    delegate.should_receive(:check_has_foo).with(:a).and_return(true)
    lambda {
      actual.should_not have_foo(:a) { |foo| delegate.check_has_foo(foo) }
    }.should fail_with("expected #has_foo?(:a) to return false, got true")
  end

  it "should fail when actual does not respond to :has_sym?" do
    delegate = mock("delegate", :check_has_foo => true)
    lambda {
      Object.new.should_not have_foo(:a) { |foo| delegate.check_has_foo(foo) }
    }.should raise_error(NameError)
  end
end


describe "has" do
  it "should work when the target implements #send" do
    o = {:a => "A"}
    def o.send(*args); raise "DOH! Library developers shouldn't use #send!" end
    lambda {
      o.should have_key(:a)
    }.should_not raise_error
  end
end
