require 'spec_helper'

describe "should raise_exception" do
  it "should pass if anything is raised" do
    lambda {raise}.should raise_exception
  end
  
  it "should fail if nothing is raised" do
    lambda {
      lambda {}.should raise_exception
    }.should fail_with("expected Exception but nothing was raised")
  end
end

describe "should raise_error" do
  it "should pass if anything is raised" do
    lambda {raise}.should raise_error
  end
  
  it "should fail if nothing is raised" do
    lambda {
      lambda {}.should raise_error
    }.should fail_with("expected Exception but nothing was raised")
  end
end

describe "should raise_exception {|e| ... }" do
  it "passes if there is an exception" do
    ran = false
    lambda { non_existent_method }.should raise_exception {|e|
      ran = true
    }
    ran.should be_true
  end

  it "passes the exception to the block" do
    exception = nil
    lambda { non_existent_method }.should raise_exception {|e|
      exception = e
    }
    exception.should be_kind_of(NameError)
  end
end

describe "should_not raise_exception" do
  it "should pass if nothing is raised" do
    lambda {}.should_not raise_exception
  end
  
  it "should fail if anything is raised" do
    lambda {
      lambda {raise}.should_not raise_exception
    }.should fail_with("expected no Exception, got RuntimeError")
  end
end

describe "should raise_exception(message)" do
  it "should pass if RuntimeError is raised with the right message" do
    lambda {raise 'blah'}.should raise_exception('blah')
  end
  it "should pass if RuntimeError is raised with a matching message" do
    lambda {raise 'blah'}.should raise_exception(/blah/)
  end
  it "should pass if any other exception is raised with the right message" do
    lambda {raise NameError.new('blah')}.should raise_exception('blah')
  end
  it "should fail if RuntimeError exception is raised with the wrong message" do
    lambda do
      lambda {raise 'blarg'}.should raise_exception('blah')
    end.should fail_with("expected Exception with \"blah\", got #<RuntimeError: blarg>")
  end
  it "should fail if any other exception is raised with the wrong message" do
    lambda do
      lambda {raise NameError.new('blarg')}.should raise_exception('blah')
    end.should fail_with("expected Exception with \"blah\", got #<NameError: blarg>")
  end
end

describe "should_not raise_exception(message)" do
  it "should pass if RuntimeError exception is raised with the different message" do
    lambda {raise 'blarg'}.should_not raise_exception('blah')
  end
  it "should pass if any other exception is raised with the wrong message" do
    lambda {raise NameError.new('blarg')}.should_not raise_exception('blah')
  end
  it "should fail if RuntimeError is raised with message" do
    lambda do
      lambda {raise 'blah'}.should_not raise_exception('blah')
    end.should fail_with(%Q|expected no Exception with "blah", got #<RuntimeError: blah>|)
  end
  it "should fail if any other exception is raised with message" do
    lambda do
      lambda {raise NameError.new('blah')}.should_not raise_exception('blah')
    end.should fail_with(%Q|expected no Exception with "blah", got #<NameError: blah>|)
  end
end

describe "should raise_exception(NamedError)" do
  it "should pass if named exception is raised" do
    lambda { non_existent_method }.should raise_exception(NameError)
  end
  
  it "should fail if nothing is raised" do
    lambda {
      lambda { }.should raise_exception(NameError)
    }.should fail_with("expected NameError but nothing was raised")
  end
  
  it "should fail if another exception is raised (NameError)" do
    lambda {
      lambda { raise }.should raise_exception(NameError)
    }.should fail_with("expected NameError, got RuntimeError")
  end
  
  it "should fail if another exception is raised (NameError)" do
    lambda {
      lambda { load "non/existent/file" }.should raise_exception(NameError)
    }.should fail_with(/expected NameError, got #<LoadError/)
  end
end

describe "should_not raise_exception(NamedError)" do
  it "should pass if nothing is raised" do
    lambda { }.should_not raise_exception(NameError)
  end
  
  it "should pass if another exception is raised" do
    lambda { raise }.should_not raise_exception(NameError)
  end
  
  it "should fail if named exception is raised" do
    lambda {
      lambda { 1 + 'b' }.should_not raise_exception(TypeError)
    }.should fail_with(/expected no TypeError, got #<TypeError: String can't be/)
  end  
end

describe "should raise_exception(NamedError, exception_message) with String" do
  it "should pass if named exception is raised with same message" do
    lambda { raise "example message" }.should raise_exception(RuntimeError, "example message")
  end
  
  it "should fail if nothing is raised" do
    lambda {
      lambda {}.should raise_exception(RuntimeError, "example message")
    }.should fail_with("expected RuntimeError with \"example message\" but nothing was raised")
  end
  
  it "should fail if incorrect exception is raised" do
    lambda {
      lambda { raise }.should raise_exception(NameError, "example message")
    }.should fail_with("expected NameError with \"example message\", got RuntimeError")
  end
  
  it "should fail if correct exception is raised with incorrect message" do
    lambda {
      lambda { raise RuntimeError.new("not the example message") }.should raise_exception(RuntimeError, "example message")
    }.should fail_with(/expected RuntimeError with \"example message\", got #<RuntimeError: not the example message/)
  end
end

describe "should raise_exception(NamedError, exception_message) { |err| ... }" do
  it "should yield exception if named exception is raised with same message" do
    ran = false

    lambda {
      raise "example message"
    }.should raise_exception(RuntimeError, "example message") { |err|
      ran = true
      err.class.should == RuntimeError
      err.message.should == "example message"
    }

    ran.should == true
  end

  it "yielded block should be able to fail on it's own right" do
    ran, passed = false, false

    lambda {
      lambda {
        raise "example message"
      }.should raise_exception(RuntimeError, "example message") { |err|
        ran = true
        5.should == 4
        passed = true
      }
    }.should fail_with(/expected: 4/m)

    ran.should == true
    passed.should == false
  end

  it "should NOT yield exception if no exception was thrown" do
    ran = false

    lambda {
      lambda {}.should raise_exception(RuntimeError, "example message") { |err|
        ran = true
      }
    }.should fail_with("expected RuntimeError with \"example message\" but nothing was raised")

    ran.should == false
  end

  it "should not yield exception if exception class is not matched" do
    ran = false

    lambda {
      lambda {
        raise "example message"
      }.should raise_exception(SyntaxError, "example message") { |err|
        ran = true
      }
    }.should fail_with("expected SyntaxError with \"example message\", got #<RuntimeError: example message>")

    ran.should == false
  end

  it "should NOT yield exception if exception message is not matched" do
    ran = false

    lambda {
      lambda {
        raise "example message"
      }.should raise_exception(RuntimeError, "different message") { |err|
        ran = true
      }
    }.should fail_with("expected RuntimeError with \"different message\", got #<RuntimeError: example message>")

    ran.should == false
  end
end

describe "should_not raise_exception(NamedError, exception_message) { |err| ... }" do
  it "should pass if nothing is raised" do
    ran = false

    lambda {}.should_not raise_exception(RuntimeError, "example message") { |err|
      ran = true
    }

    ran.should == false
  end

  it "should pass if a different exception is raised" do
    ran = false

    lambda { raise }.should_not raise_exception(NameError, "example message") { |err|
      ran = true
    }

    ran.should == false
  end

  it "should pass if same exception is raised with different message" do
    ran = false

    lambda {
      raise RuntimeError.new("not the example message")
    }.should_not raise_exception(RuntimeError, "example message") { |err|
      ran = true
    }

    ran.should == false
  end

  it "should fail if named exception is raised with same message" do
    ran = false

    lambda {
      lambda {
        raise "example message"
      }.should_not raise_exception(RuntimeError, "example message") { |err|
        ran = true
      }
    }.should fail_with("expected no RuntimeError with \"example message\", got #<RuntimeError: example message>")

    ran.should == false
  end
end

describe "should_not raise_exception(NamedError, exception_message) with String" do
  it "should pass if nothing is raised" do
    lambda {}.should_not raise_exception(RuntimeError, "example message")
  end
  
  it "should pass if a different exception is raised" do
    lambda { raise }.should_not raise_exception(NameError, "example message")
  end
  
  it "should pass if same exception is raised with different message" do
    lambda { raise RuntimeError.new("not the example message") }.should_not raise_exception(RuntimeError, "example message")
  end
  
  it "should fail if named exception is raised with same message" do
    lambda {
      lambda { raise "example message" }.should_not raise_exception(RuntimeError, "example message")
    }.should fail_with("expected no RuntimeError with \"example message\", got #<RuntimeError: example message>")
  end
end

describe "should raise_exception(NamedError, exception_message) with Regexp" do
  it "should pass if named exception is raised with matching message" do
    lambda { raise "example message" }.should raise_exception(RuntimeError, /ample mess/)
  end
  
  it "should fail if nothing is raised" do
    lambda {
      lambda {}.should raise_exception(RuntimeError, /ample mess/)
    }.should fail_with("expected RuntimeError with message matching /ample mess/ but nothing was raised")
  end
  
  it "should fail if incorrect exception is raised" do
    lambda {
      lambda { raise }.should raise_exception(NameError, /ample mess/)
    }.should fail_with("expected NameError with message matching /ample mess/, got RuntimeError")
  end
  
  it "should fail if correct exception is raised with incorrect message" do
    lambda {
      lambda { raise RuntimeError.new("not the example message") }.should raise_exception(RuntimeError, /less than ample mess/)
    }.should fail_with("expected RuntimeError with message matching /less than ample mess/, got #<RuntimeError: not the example message>")
  end
end

describe "should_not raise_exception(NamedError, exception_message) with Regexp" do
  it "should pass if nothing is raised" do
    lambda {}.should_not raise_exception(RuntimeError, /ample mess/)
  end
  
  it "should pass if a different exception is raised" do
    lambda { raise }.should_not raise_exception(NameError, /ample mess/)
  end
  
  it "should pass if same exception is raised with non-matching message" do
    lambda { raise RuntimeError.new("non matching message") }.should_not raise_exception(RuntimeError, /ample mess/)
  end
  
  it "should fail if named exception is raised with matching message" do
    lambda {
      lambda { raise "example message" }.should_not raise_exception(RuntimeError, /ample mess/)
    }.should fail_with("expected no RuntimeError with message matching /ample mess/, got #<RuntimeError: example message>")
  end
end
