# frozen_string_literal: true

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
        if ActiveRecord::Base.connection.data_source_exists? 'field_groups'
          FieldGroup.where(klass_name: name).order(:position)
        else
          []
        end
      end

      def fields
        field_groups.map(&:fields).flatten
      end

      def serialize_custom_fields!
        fields.each do |field|
          serialize(field.name.to_sym, Array) if field.as == 'check_boxes'
        end
      end

      # Shows custom field select options in ransack search form
      def ransack_column_select_options
        field_groups.each_with_object({}) do |group, hash|
          group.fields.select { |f| f.collection.present? }.each do |field|
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
        field_groups.map(&:fields).flatten.each { |f| f.custom_validator(self) }
      end

      def assign_attributes(new_attributes)
        super
      # If attribute is unknown, a new custom field may have been added.
      # Refresh columns and try again.
      rescue ActiveRecord::UnknownAttributeError
        self.class.reset_column_information
        super
      end

      def method_missing(method_id, *args, &block)
        if method_id.to_s.match?(/\Acf_.*[^=]\Z/)
          # Refresh columns and try again.
          self.class.reset_column_information
          # If new record, create new object from class, else reload class
          object = new_record? ? self.class.new : (reload && self)
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
