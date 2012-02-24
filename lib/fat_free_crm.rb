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

# Plugin dependencies
require Rails.root.join('vendor/plugins/is_paranoid/init')

# Overrides
require "overrides/authlogic/session/cookies"
require "overrides/simple_form/action_view_extensions/form_helper"
require "overrides/rails/text_helper"
require "overrides/active_record/schema_dumper"

# Fat Free CRM
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
require "fat_free_crm/dropbox" if defined?(::Rake)
require "fat_free_crm/plugin"
