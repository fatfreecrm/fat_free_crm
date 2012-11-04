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
  module Fields

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def has_fields
        unless included_modules.include?(InstanceMethods)
          extend SingletonMethods
          include InstanceMethods
          serialize_custom_fields!
          validate :custom_fields_validator
        end
      end
    end

    module SingletonMethods
      def field_groups
        if ActiveRecord::Base.connection.table_exists? 'field_groups'
          FieldGroup.where(:klass_name => self.name).order(:position)
        else
          []
        end
      end

      def fields
        field_groups.map(&:fields).flatten
      end
      
      def serialize_custom_fields!
        fields.each do |field|
          if !serialized_attributes.keys.include?(field.name) and field.as == 'check_boxes'
            serialize(field.name.to_sym, Array)
          end
        end
      end

    end

    module InstanceMethods
      def field_groups
        field_groups = self.class.field_groups
        respond_to?(:tag_ids) ? field_groups.with_tags(tag_ids) : field_groups
      end
      
      # run custom field validations on this object
      #------------------------------------------------------------------------------
      def custom_fields_validator
        self.field_groups.map(&:fields).flatten.each{|f| f.custom_validator(self) }
      end

      def assign_attributes(new_attributes, options = {})
        super
      # If attribute is unknown, a new custom field may have been added.
      # Refresh columns and try again.
      rescue ActiveRecord::UnknownAttributeError
        self.class.reset_column_information
        super
      end

      def method_missing(method_id, *args, &block)
        if method_id.to_s =~ /^cf_/
          # Refresh columns and try again.
          self.class.reset_column_information
          # If new record, create new object from class, else reload class
          object = self.new_record? ? self.class.new : (self.reload && self)
          # ensure serialization is setup if needed
          self.class.serialize_custom_fields!
          # Try again if object now responds to method, else return nil
          object.respond_to?(method_id) ? object.send(method_id, *args) : nil
        else
          super
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, FatFreeCRM::Fields)
