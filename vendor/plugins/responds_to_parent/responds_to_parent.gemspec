spec = Gem::Specification.new do |s|
  s.name        = 'responds_to_parent'
  s.version     = '1.0.20091013'
  s.homepage    = 'http://github.com/markcatley/responds_to_parent'
  s.summary     = "[Rails] Adds 'responds_to_parent' to your controller to" +
                  'respond to the parent document of your page.'            +
                  'Make Ajaxy file uploads by posting the form to a hidden' +
                  'iframe, and respond with RJS to the parent window.'
  
  s.files = %w( README Rakefile MIT-LICENSE
                lib/responds_to_parent.rb
                lib/responds_to_parent/action_controller.rb
                lib/responds_to_parent/selector_assertion.rb
                test/responds_to_parent_test.rb
                test/assert_select_parent_test.rb)
end
