# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{simple_column_search}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Elijah Miller"]
  s.date = %q{2009-02-01}
  s.description = %q{Quick and dirty multi column LIKE searches.}
  s.email = %q{elijah.miller@gmail.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/simple_column_search.rb", "README.rdoc"]
  s.files = ["CHANGELOG", "init.rb", "lib/simple_column_search.rb", "Manifest", "Rakefile", "README.rdoc", "spec/models.rb", "spec/spec_helper.rb", "simple_column_search.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jqr/simple_column_search}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Simple_column_search", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{simple_column_search}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Quick and dirty multi column LIKE searches.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
