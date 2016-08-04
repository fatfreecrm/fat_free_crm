# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'fat_free_crm/version'

Gem::Specification.new do |gem|
  gem.name = 'fat_free_crm'
  gem.authors = ['Michael Dvorkin', 'Ben Tillman', 'Nathan Broadbent', 'Stephen Kenworthy']
  gem.summary = 'Fat Free CRM'
  gem.description = 'An open source, Ruby on Rails customer relationship management platform'
  gem.homepage = 'http://fatfreecrm.com'
  gem.email = ['mike@fatfreecrm.com', 'nathan@fatfreecrm.com', 'warp@fatfreecrm.com', 'steveyken@gmail.com']
  gem.files = `git ls-files`.split("\n")
  gem.version = FatFreeCRM::VERSION::STRING
  gem.required_ruby_version = '>= 2.0.0'
  gem.license = 'MIT'

  gem.add_dependency 'rails',               '~> 4.2.0'
  gem.add_dependency 'rails-observers'
  # Sprockets 2.2.3 appears to have a bug resolving assets from the engine update to '>= 3.0.0 once released'
  gem.add_dependency 'sprockets-rails',     '2.2.2'
  gem.add_dependency 'responders',          '~> 2.0'
  gem.add_dependency 'jquery-rails'
  gem.add_dependency 'jquery-migrate-rails'
  gem.add_dependency 'jquery-ui-rails'
  gem.add_dependency 'select2-rails', '~> 3.5.9.3'
  gem.add_dependency 'simple_form'
  gem.add_dependency 'will_paginate'
  gem.add_dependency 'paperclip'
  # Manually added paperclip gem dependency "cocaine" in order to fix load error: "no such file to load -- cocaine"
  gem.add_dependency 'cocaine'
  gem.add_dependency 'paper_trail',         '>= 4.0.0.beta2'
  gem.add_dependency 'authlogic',           '>= 3.4.4'
  gem.add_dependency 'acts_as_commentable'
  gem.add_dependency 'acts-as-taggable-on', '>= 3.4.3'
  gem.add_dependency 'dynamic_form'
  gem.add_dependency 'haml'
  gem.add_dependency 'sass'
  gem.add_dependency 'acts_as_list'
  gem.add_dependency 'ffaker',              '>= 2'
  gem.add_dependency 'cancancan'
  gem.add_dependency 'font-awesome-rails'
  gem.add_dependency 'premailer'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'responds_to_parent'
  gem.add_dependency 'rails3-jquery-autocomplete'
  gem.add_dependency 'psych', '~> 1'        if RUBY_VERSION.to_f < 2.0
  gem.add_dependency 'thor'
  gem.add_dependency 'rails_autolink'
  gem.add_dependency 'coffee-script-source', '~>1.8.0' # pegged until https://github.com/jashkenas/coffeescript/issues/3829 is resolved
  gem.add_dependency 'country_select'

  # FatFreeCRM has released it's own versions of the following gems:
  #-----------------------------------------------------------------
  gem.add_dependency 'ransack_ui',          '>= 1.3.1'
  gem.add_dependency 'ransack',             '~> 1.6.2'
  gem.add_dependency 'email_reply_parser_ffcrm'
end
