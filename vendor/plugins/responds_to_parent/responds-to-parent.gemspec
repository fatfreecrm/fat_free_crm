spec = Gem::Specification.new do |s|
  s.name        = 'responds-to-parent'
  s.version     = '1.0.20090521'
  s.homepage    = 'http://constancy.rubyforge.org/'
  s.summary     = "[Rails] Adds 'responds_to_parent' to your controller to" +
                  'respond to the parent document of your page.'
                  'Make Ajaxy file uploads by posting the form to a hidden' +
                  'iframe, and respond with RJS to the parent window.'
  
  s.files = %w( README Rakefile MIT-LICENSE rails/init.rb
                lib/responds_to_parent.rb
                lib/parent_selector_assertion.rb
                test/responds_to_parent_test.rb
                test/assert_select_parent_test.rb)
end
