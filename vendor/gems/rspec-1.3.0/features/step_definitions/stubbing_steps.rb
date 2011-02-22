When /^I stub "([^\"]*)" on "([^\"]*)" to "([^\"]*)"$/ do |method_name, const_name, value|
  const = Object.const_get(const_name)
  const.stub!(method_name.to_sym).and_return(value)
end

Then /^calling "([^\"]*)" on "([^\"]*)" should return "([^\"]*)"$/ do |method_name, const_name, value|
  const = Object.const_get(const_name)
  const.send(method_name.to_sym).should == value
end

Then /^"([^\"]*)" should not be defined on "([^\"]*)"$/ do |method_name, const_name|
  const = Object.const_get(const_name)
  lambda {
    const.send(method_name.to_sym)
  }.should raise_error(NameError, /#{method_name}/)
end
