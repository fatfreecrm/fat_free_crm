require_relative 'lib/fat_free_crm/version'

Gem::Specification.new do |gem|
  gem.name = 'fat_free_crm'
  gem.authors = ['Ideacrew']
  gem.summary = 'Fat Free CRM'
  gem.description = 'An open source, Ruby on Rails customer relationship management platform'
  gem.homepage = 'http://fatfreecrm.com'
  gem.email = ['info@ideacrew.com']
  gem.version = FatFreeCrm::VERSION::STRING
  gem.required_ruby_version = '>= 2.4.0'
  gem.license = 'MIT'

  gem.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|gem|features)/}) }
  end
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency 'rails', '~> 6.0'
  

  gem.add_dependency 'sass-rails'
  gem.add_dependency 'coffee-rails'
  gem.add_dependency 'uglifier'
  gem.add_dependency 'execjs'
  gem.add_dependency 'bootsnap' #, require: false
  gem.add_dependency 'tzinfo-data' #, platforms: %i[mingw mswin x64_mingw jruby]
  gem.add_dependency 'activejob', '~> 6.0'
  gem.add_dependency 'rails-observers'

  # FatFreeCrm has released it's own versions of the following gems:
  #-----------------------------------------------------------------
  gem.add_dependency 'ransack_ui', '~> 1.3', '>= 1.3.1'
  gem.add_dependency 'ransack', '>= 1.6.2'
  gem.add_dependency 'email_reply_parser_ffcrm'
  gem.add_dependency 'aws-sdk-s3'

  # Development dependencies
  #-----------------------------------------------------------------
  gem.add_development_dependency 'pry-byebug'
  gem.add_development_dependency 'capybara'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rspec-activemodel-mocks'
  gem.add_development_dependency 'headless'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'selenium-webdriver'
  gem.add_development_dependency 'webdrivers'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'zeus' #, platform: :ruby
  gem.add_development_dependency 'timecop'

  gem.add_development_dependency 'devise'
  gem.add_development_dependency 'devise-i18n'
  gem.add_development_dependency 'devise-encryptable'
  gem.add_dependency 'cancancan'
  gem.add_development_dependency 'rails-i18n'
  gem.add_development_dependency 'active_model_serializers'
  gem.add_development_dependency 'activemodel-serializers-xml'
  gem.add_development_dependency 'sprockets-rails'
  gem.add_development_dependency 'responders'
  gem.add_development_dependency 'jquery-rails'
  gem.add_development_dependency 'jquery-migrate-rails'
  gem.add_development_dependency 'jquery-ui-rails'
  gem.add_development_dependency 'select2-rails'
  gem.add_development_dependency 'simple_form'
  gem.add_development_dependency 'will_paginate'
  gem.add_dependency 'paperclip'
  gem.add_dependency 'paper_trail'
  gem.add_dependency 'acts_as_commentable'
  gem.add_dependency 'acts-as-taggable-on'
  gem.add_development_dependency 'dynamic_form'
  gem.add_development_dependency 'haml'
  gem.add_development_dependency 'sass'
  gem.add_dependency 'acts_as_list'
  gem.add_development_dependency 'ffaker', '>= 2'
  gem.add_development_dependency 'font-awesome-rails'
  gem.add_development_dependency 'premailer'
  gem.add_development_dependency 'nokogiri'
  gem.add_development_dependency 'responds_to_parent'
  gem.add_dependency 'rails3-jquery-autocomplete'
  gem.add_development_dependency 'thor'
  gem.add_development_dependency 'rails_autolink'
  gem.add_development_dependency 'coffee-script-source'
  gem.add_development_dependency 'country_select'
  gem.add_development_dependency 'ransack', '>= 1.6.2'
  gem.add_development_dependency 'ransack_ui', '~> 1.3', '>= 1.3.1'
  gem.add_development_dependency 'ransack_chronic'
end
