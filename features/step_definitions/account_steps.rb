Given /^an account named "([^"]+)"?$/ do |name|
  @account = Factory(:account, {:name => name})
end

And /^the account is tagged with "([^"]*)"$/ do |tag_name|
  @account.update_attribute(:tag_list, tag_name)
end

