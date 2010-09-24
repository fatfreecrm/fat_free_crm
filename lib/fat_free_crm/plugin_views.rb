# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
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
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module FatFreeCRM
  # The following is taken from PrependEngineViews plugin for Redmine
  # (see http://github.com/edavis10/prepend_engine_views/blob/master/init.rb)
  # It basically lets any Fat Free CRM plugin override default views.
  module PrependEngineViews
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :add_engine_view_paths, :prepend
      end
    end

    module InstanceMethods
      # Patch Rails so engine's views are prepended to the view_path,
      # thereby letting plugins override application views
      def add_engine_view_paths_with_prepend
        paths = ActionView::PathSet.new(engines.collect(&:view_path))
        ActionController::Base.view_paths.unshift(*paths)
        ActionMailer::Base.view_paths.unshift(*paths) if configuration.frameworks.include?(:action_mailer)
      end
    end
  end
end
