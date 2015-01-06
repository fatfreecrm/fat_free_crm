# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
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
          FieldGroup.where(klass_name: self.name).order(:position)
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

      # Shows custom field select options in ransack search form
      def ransack_column_select_options
        field_groups.each_with_object({}) do |group, hash|
          group.fields.select{|f| f.collection.present? }.each do |field|
            hash[field.name] = field.collection.each_with_object({}) do |option, options|
              options[option] = option
            end
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
    end
  end
end

ActiveRecord::Base.send(:include, FatFreeCRM::Fields)
