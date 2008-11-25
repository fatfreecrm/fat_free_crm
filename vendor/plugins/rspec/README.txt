= RSpec

* http://rspec.info
* http://rspec.info/rdoc/
* http://rubyforge.org/projects/rspec
* http://github.com/dchelimsky/rspec/wikis
* mailto:rspec-devel@rubyforge.org

== DESCRIPTION:

RSpec is a Behaviour Driven Development framework with tools to express User
Stories with Executable Scenarios and Executable Examples at the code level.

== FEATURES:

* Spec::Story provides a framework for expressing User Stories and Scenarios
* Spec::Example provides a framework for expressing Isolated Examples
* Spec::Matchers provides Expression Matchers for use with Spec::Expectations and Spec::Mocks.

== SYNOPSIS:

Spec::Expectations supports setting expectations on your objects so you
can do things like:

  result.should equal(expected_result)
  
Spec::Mocks supports creating Mock Objects, Stubs, and adding Mock/Stub
behaviour to your existing objects.

== INSTALL:

  [sudo] gem install rspec

 or

  git clone git://github.com/dchelimsky/rspec.git
  cd rspec
  rake gem
  rake install_gem
