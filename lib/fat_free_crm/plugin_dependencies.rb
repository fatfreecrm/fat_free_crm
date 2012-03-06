# Plugin dependencies
%w(country_select dynamic_form gravatar_image_tag responds_to_parent).each do |plugin|
  $:.unshift File.join(File.dirname(__FILE__), '..', plugin, 'lib')
  require plugin
end