require 'fileutils'

Given /^the (\w+) app is setup with the latest generators$/ do |app_name|
  email_specs_path = "#{root_dir}/examples/#{app_name}/features/step_definitions/email_steps.rb"
  FileUtils.rm(email_specs_path) if File.exists?(email_specs_path)
  FileUtils.mkdir_p("#{root_dir}/examples/#{app_name}/vendor/plugins/email_spec")
  FileUtils.cp_r("#{root_dir}/rails_generators", "#{root_dir}/examples/#{app_name}/vendor/plugins/email_spec/")

  Dir.chdir(File.join(root_dir, 'examples', app_name)) do
    system "ruby ./script/generate email_spec"
  end
end

Given /^the (\w+) app is setup with the latest email steps$/ do |app_name|
  email_specs_path = "#{root_dir}/examples/#{app_name}/features/step_definitions/email_steps.rb"
  FileUtils.rm(email_specs_path) if File.exists?(email_specs_path)
  FileUtils.cp_r("#{root_dir}/rails_generators/email_spec/templates/email_steps.rb", email_specs_path)
end

When /^I run "([^\"]*)" in the (\w+) app$/ do |cmd, app_name|
  cmd.gsub!('cucumber', "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY}")
  Dir.chdir(File.join(root_dir, 'examples', app_name)) do
    @output = `#{cmd}`
  end
end

Then /^the (\w+) app should have the email steps in place$/ do |app_name|
  email_specs_path = "#{root_dir}/examples/#{app_name}/features/step_definitions/email_steps.rb"
  File.exists?(email_specs_path).should == true
end

Then /^I should see the following summary report:$/ do |expected_report|
  @output.should include(expected_report)
end
