# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ransack_ui/version'

Gem::Specification.new do |gem|
  gem.name          = "ransack_ui"
  gem.version       = RansackUI::VERSION
  gem.authors       = ["Nathan Broadbent"]
  gem.email         = ["nathan.f77@gmail.com"]
  gem.description   = "Framework for building a search UI with Ransack"
  gem.summary       = "UI Builder for Ransack"
  gem.homepage      = "https://github.com/ndbroadbent/ransack_ui"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'ransack_chronic', '>= 1.1.0'
  gem.add_dependency 'ransack'
end
