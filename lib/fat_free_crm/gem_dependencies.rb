# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

require 'rails/all'
require 'jquery-rails'
require 'select2-rails'
require 'prototype-rails'
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
require 'devise'
require 'chosen-rails'
require 'ajax-chosen-rails'
require 'ransack'
require 'ransack_ui'
require 'paper_trail'
require 'cancan'
require 'rails3-jquery-autocomplete'
require 'valium'
require 'ffaker'
require 'premailer'
require 'nokogiri'

# Load redcloth if available (for textile markup in emails)
begin
  require 'redcloth'
rescue LoadError
end
