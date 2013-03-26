# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCRM
  class << self
    # Return either Application or Engine,
    # depending on how Fat Free CRM has been loaded
    def application
      defined?(FatFreeCRM::Engine) ? Engine : Application
    end

    def root
      application.root
    end
  end
end

# Load Fat Free CRM as a Rails Engine, unless running as a Rails Application
unless defined?(FatFreeCRM::Application)
  require 'fat_free_crm/engine'
end

# Our settings.yml structure requires the Syck YAML parser
require 'fat_free_crm/syck_yaml'

# Require gem dependencies, monkey patches, and vendored plugins (in lib)
require "fat_free_crm/gem_dependencies"
require "fat_free_crm/gem_ext"
require "fat_free_crm/plugin_dependencies"

require "fat_free_crm/version"
require "fat_free_crm/core_ext"
require "fat_free_crm/comment_extensions"
require "fat_free_crm/exceptions"
require "fat_free_crm/export_csv"
require "fat_free_crm/errors"
require "fat_free_crm/i18n"
require "fat_free_crm/permissions"
require "fat_free_crm/exportable"
require "fat_free_crm/renderers"
require "fat_free_crm/fields"
require "fat_free_crm/sortable"
require "fat_free_crm/tabs"
require "fat_free_crm/callback"
require "fat_free_crm/plugin"
require "fat_free_crm/view_factory"
