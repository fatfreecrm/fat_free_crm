# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'fat_free_crm/version'

Gem::Specification.new do |gem|
  gem.name = 'fat_free_crm'
  gem.authors = ['Michael Dvorkin', 'Ben Tillman', 'Nathan Broadbent', 'Stephen Kenworthy']
  gem.summary = 'Fat Free CRM'
  gem.description = 'Fat Free CRM'
  gem.files = `git ls-files`.split("\n")
  gem.version = FatFreeCRM::VERSION::STRING

  gem.add_dependency 'rails',               '~> 3.2.1'
  gem.add_dependency 'prototype-rails'
  gem.add_dependency 'jquery-rails'
  gem.add_dependency 'simple_form',         '~> 1.5.2'
  gem.add_dependency 'will_paginate',       '~> 3.0.2'
  gem.add_dependency 'paperclip',           '~> 2.5.2'
  gem.add_dependency 'paper_trail'
  gem.add_dependency 'authlogic',           '~> 3.1.0'
  gem.add_dependency 'acts_as_commentable', '~> 3.0.1'
  gem.add_dependency 'acts-as-taggable-on', '~> 2.2.1'
  gem.add_dependency 'haml',                '~> 3.1.3'
  gem.add_dependency 'acts_as_list',        '~> 0.1.4'
  gem.add_dependency 'ffaker',              '>= 1.12.0'
  gem.add_dependency 'uglifier'
  gem.add_dependency 'chosen-rails'
  gem.add_dependency 'ajax-chosen-rails',   '>= 0.1.5'
  gem.add_dependency 'ransack'

  gem.add_development_dependency 'rspec-rails',  '~> 2.8.1'
  gem.add_development_dependency 'capybara'
  gem.add_development_dependency 'sass-rails'
  gem.add_development_dependency 'coffee-rails'
  gem.add_development_dependency 'therubyracer'
  gem.add_development_dependency 'spork'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'fuubar'
  gem.add_development_dependency 'factory_girl'
end


