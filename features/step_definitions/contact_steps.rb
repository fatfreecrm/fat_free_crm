Given /^a contact with full name "([^"]+)"$/ do |name|
  first_name, last_name = name.scan(/(.*) ([^ ]*)$/).flatten
  @contact = Factory(:contact, :first_name => first_name,
                               :last_name  => last_name)
end

