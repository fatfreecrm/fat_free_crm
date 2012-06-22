# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'fat_free_crm/version'

Gem::Specification.new do |gem|
  gem.name = 'fat_free_crm'
  gem.authors = ['Michael Dvorkin', 'Ben Tillman', 'Nathan Broadbent', 'Stephen Kenworthy']
  gem.summary = 'Fat Free CRM'
  gem.description = 'An open source, Ruby on Rails customer relationship management platform'
  gem.homepage = 'http://fatfreecrm.com'
  gem.email = ['mike@fatfreecrm.com', 'nathan@fatfreecrm.com', 'warp@fatfreecrm.com']
  gem.files = `git ls-files`.split("\n")
  gem.version = FatFreeCRM::VERSION::STRING

  gem.add_dependency 'rails',               '~> 3.2.2'
  gem.add_dependency 'prototype-rails'
  gem.add_dependency 'jquery-rails'
  gem.add_dependency 'simple_form',         '~> 2.0.1'
  gem.add_dependency 'will_paginate',       '~> 3.0.2'
  gem.add_dependency 'paperclip',           '~> 2.7.0'
  gem.add_dependency 'paper_trail'
  gem.add_dependency 'authlogic',           '3.1.0'
  gem.add_dependency 'acts_as_commentable', '~> 3.0.1'
  gem.add_dependency 'acts-as-taggable-on', '~> 2.2.1'
  gem.add_dependency 'dynamic_form'
  gem.add_dependency 'haml',                '~> 3.1.3'
  gem.add_dependency 'sass',                '~> 3.1.10'
  gem.add_dependency 'acts_as_list',        '~> 0.1.4'
  gem.add_dependency 'ffaker',              '>= 1.12.0'
  gem.add_dependency 'cancan'
  gem.add_dependency 'premailer'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'squeel',              '~> 0.9.3'
  gem.add_dependency 'responds_to_parent',  '>= 1.1.0'

  # FatFreeCRM has released it's own versions of the following gems:
  #-----------------------------------------------------------------
  gem.add_dependency 'ransack_ffcrm',       '~> 0.6.0'
  gem.add_dependency 'ajax-chosen-rails',   '>= 0.2.0'  # (now depends on chosen-rails_ffcrm)
  gem.add_dependency 'email_reply_parser_ffcrm'

end
