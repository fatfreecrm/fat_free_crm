# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'rails/all'
require 'jquery-rails'
require 'select2-rails'
require 'haml'
require 'sass'
require 'acts_as_commentable'
require 'acts_as_list'
require 'acts-as-taggable-on'
require 'responds_to_parent'
require 'dynamic_form'
require 'paperclip'
require 'simple_form'
require 'will_paginate'
require 'authlogic'
require 'ransack'
require 'ransack_ui'
require 'paper_trail'
require 'cancan'
require 'rails3-jquery-autocomplete'
require 'valium'
require 'ffaker'
require 'premailer'
require 'nokogiri'
require 'font-awesome-rails'

# Load redcloth if available (for textile markup in emails)
begin
  require 'redcloth'
rescue LoadError
end
