# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'fat_free_crm/version'

Gem::Specification.new do |gem|
  gem.name = 'fat_free_crm'
  gem.authors = ['Michael Dvorkin', 'Stephen Kenworthy', "Daniel O'Connor"]
  gem.summary = 'Fat Free CRM'
  gem.description = 'An open source, Ruby on Rails customer relationship management platform'
  gem.homepage = 'http://fatfreecrm.com'
  gem.email = ['mike@fatfreecrm.com', 'steveyken@gmail.com', 'daniel.oconnor@gmail.com']
  gem.files = Dir["{app,config,db,lib,vendor,public,bin,log/script}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "config.ru", "CHANGELOG.md", "CONTRIBUTING.md"]
  gem.version = FatFreeCRM::VERSION::STRING
  gem.required_ruby_version = '>= 2.4.0'
  gem.license = 'MIT'

  gem.add_dependency 'rails', '~> 6.1.0'
  gem.add_dependency 'rails-i18n'
  gem.add_dependency 'rails-observers'
  gem.add_dependency 'activemodel-serializers-xml'
  gem.add_dependency 'sprockets-rails',     '>= 3.0.0'
  gem.add_dependency 'responders',          '~> 3.0'
  gem.add_dependency 'jquery-rails'
  gem.add_dependency 'jquery-migrate-rails'
  gem.add_dependency 'jquery-ui-rails'
  gem.add_dependency 'select2-rails'
  gem.add_dependency 'simple_form'
  gem.add_dependency 'will_paginate'
  gem.add_dependency 'paperclip'
  gem.add_dependency 'paper_trail',         '~> 12.0.0'
  gem.add_dependency 'devise',              '~> 4.6'
  gem.add_dependency 'devise-encryptable',  '~> 0.2.0'
  gem.add_dependency 'acts_as_commentable', '~> 6.0.0'
  gem.add_dependency 'acts-as-taggable-on', '>= 3.4.3'
  gem.add_dependency 'dynamic_form'
  gem.add_dependency 'haml'
  gem.add_dependency 'sass'
  gem.add_dependency 'acts_as_list'
  gem.add_dependency 'ffaker', '>= 2'
  gem.add_dependency 'cancancan', '>= 3.3.0'
  gem.add_dependency 'font-awesome-rails'
  gem.add_dependency 'premailer'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'responds_to_parent'
  gem.add_dependency 'rails3-jquery-autocomplete'
  gem.add_dependency 'thor'
  gem.add_dependency 'rails_autolink'
  gem.add_dependency 'coffee-script-source', '~> 1.8', '>= 1.8.0' # pegged until https://github.com/jashkenas/coffeescript/issues/3829 is resolved
  gem.add_dependency 'country_select'

  # FatFreeCRM has released it's own versions of the following gems:
  #-----------------------------------------------------------------
  gem.add_dependency 'ransack', '>= 1.6.2'
  gem.add_dependency 'email_reply_parser_ffcrm'
end
