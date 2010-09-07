Then /^I take a screenshot called "(.*)"$/ do |image_name|
  `mkdir -p #{RAILS_ROOT}/features/screengrabs`
  `import -window root -display :#{HEADLESS_DISPLAY} #{RAILS_ROOT}/features/screengrabs/#{image_name}` if defined? HEADLESS_DISPLAY
end
