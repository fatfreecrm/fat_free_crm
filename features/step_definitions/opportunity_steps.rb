Given /^an opportunity named "([^"]+)"(?: from "([^"]+)")?$/ do |name, account_name|
  @account = Factory(:account, (account_name ? {:name => account_name} : {}))
  @opportunity = Factory(:opportunity, :name => name, :account => @account)
end

Given /^an opportunity with params:$/ do |params|
  @opportunity = Factory(:opportunity, params.rows_hash.merge(:account => Factory(:account)))
end
