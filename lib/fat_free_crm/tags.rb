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

include ActsAsTaggableOn

module FatFreeCRM
  module Tags

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def has_tags
        unless included_modules.include?(InstanceMethods)
          include InstanceMethods
          acts_as_taggable_on :tags
        end
      end
    end

    module InstanceMethods
      def tag(tag_name)
        if (tag_record = Tag.find_by_name(tag_name)) && tag_list.include?(tag_name);
          # Return tag if it exists, else create the tag table.
          if tag_obj = send(:"tag#{tag_record.id}")
            return tag_obj
          else
            return send(:"create_tag#{tag_record.id}")
          end
        end
        nil
      end
    end

  end
end

ActiveRecord::Base.send(:include, FatFreeCRM::Tags)
