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
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.
#------------------------------------------------------------------------------
module FatFreeCRM
  module ActiveModel
    module Errors

      # Override ActiveModel::Errors#each so we could display validation
      # errors as is without rendering the attribute name. Simply place
      # a caret as the first character of the error message.
      #
      # This feature was handled by 'advanced_errors' plugin in Rails 2.x
      # version of Fat Free CRM.
      #----------------------------------------------------------------------------
      def self.included(base)
        base.class_eval do
          alias_method :each, :each_with_explicit_error
        end
      end

      def each_with_explicit_error
        each_key do |attribute|
          self[attribute].each do |error|
            if error.start_with?('^')
              yield :base, error[1..-1]   # Drop the attribute.
            else
              yield attribute, error      # This is default Rails3 behavior.
            end
          end
        end
      end

    end
  end
end
