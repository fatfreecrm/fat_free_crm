# -*- encoding: utf-8 -*-

require 'bundler'

Gem::Specification.new do |s|
  s.name = %q{is_paranoid}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeffrey Chupp"]
  s.date = %q{2009-03-20}
  s.email = %q{jeff@semanticart.com}
  s.files = [
    "init.rb",
    "lib/is_paranoid.rb",
    "README.markdown",
    "Rakefile",
    "MIT-LICENSE",
    "spec/is_paranoid_spec.rb",
    "spec/spec_helper.rb",
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jchupp/is_paranoid/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{ActiveRecord 3 compatible gem "allowing you to hide and restore records without actually deleting them."  Yes, like acts_as_paranoid, only with less code and less complexity.}
end
