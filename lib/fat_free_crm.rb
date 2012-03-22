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
require "fat_free_crm/exceptions"
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
