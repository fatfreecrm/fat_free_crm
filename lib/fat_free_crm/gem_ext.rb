# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require "fat_free_crm/gem_ext/active_support/buffered_logger"
require "fat_free_crm/gem_ext/action_controller/base"
require "fat_free_crm/gem_ext/simple_form/action_view_extensions/form_helper"
require "fat_free_crm/gem_ext/rake/task" if defined?(Rake)
