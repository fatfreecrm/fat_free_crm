# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_commentable}
  s.version = "2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cosmin Radoi, Jack Dempsey, Xelipe, Chris Eppstein"]
  s.autorequire = %q{acts_as_commentable}
  s.date = %q{2009-07-01}
  s.description = %q{Plugin/gem that provides comment functionality}
  s.email = %q{unknown@juixe.com}
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
  s.files = ["MIT-LICENSE", "README", "generators/comment", "generators/comment/comment_generator.rb", "generators/comment/templates", "generators/comment/templates/comment.rb", "generators/comment/templates/create_comments.rb", "lib/acts_as_commentable.rb", "lib/comment_methods.rb", "lib/commentable_methods.rb", "tasks/acts_as_commentable_tasks.rake", "init.rb", "install.rb"]
  s.homepage = %q{http://www.juixe.com/techknow/index.php/2006/06/18/acts-as-commentable-plugin/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Plugin/gem that provides comment functionality}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
