module RansackUI
  module Adapters
    module ActiveRecord
      module Base

        def self.extended(base)
          base.class_eval do
            class_attribute :_ransackable_associations
            class_attribute :_ransack_can_autocomplete
            self._ransackable_associations ||= []
            self._ransack_can_autocomplete = false
          end
        end

        def has_ransackable_associations(associations)
          self._ransackable_associations = associations
        end

        def ransack_can_autocomplete
          self._ransack_can_autocomplete = true
        end

        # Return array of attributes with [name, type]
        # (Default to :string type for ransackers)
        def ransackable_attributes(auth_object = nil)
          columns.map{|c| [c.name, c.type] } +
          _ransackers.keys.map {|k,v| [k, v.type || :string] }
        end

        def ransackable_associations(auth_object = nil)
          all_associations = reflect_on_all_associations.map {|a| a.name.to_s}
          if self._ransackable_associations.any?
            # Return intersection of all associations, and associations defined on the model
            all_associations & self._ransackable_associations
          else
            all_associations
          end
        end

        def ransortable_attributes(auth_object = nil)
          ransackable_attributes(auth_object).map(&:first)
        end
      end
    end
  end
end
