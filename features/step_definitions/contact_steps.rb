Given /^a contact with full name "([^"]+)"$/ do |name|
  first_name, last_name = name.scan(/(.*) ([^ ]*)$/).flatten
  @contact = Factory(:contact, :first_name => first_name,
                               :last_name  => last_name)
end

Given /^an contact with params:$/ do |params|
  @contact = Factory(:contact, params.rows_hash)
end

And /^the contact is tagged with "([^"]*)"$/ do |tag_name|
  @contact.update_attribute(:tag_list, tag_name)
end

And /^the contact has a note with the text "([^"]+)"$/ do |note|
  @comment = Factory(:comment, :commentable => @contact,
                               :comment     => note)
end

