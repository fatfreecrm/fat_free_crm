require 'ransack/adapters/active_record/base'

module Ransack
  module Adapters
    module ActiveRecord
      module Base
        # Return array of attributes with [name, type]
        # (Default to :string type for ransackers)
        def ransackable_attributes(auth_object = nil)
          columns.map{|c| [c.name, c.type] } +
          _ransackers.map {|k,v| [k, v.type || :string] }
        end

        def self.extended(base)
          alias :search :ransack unless base.method_defined? :search
          base.class_eval do
            class_attribute :_ransackers
            class_attribute :_ransackable_associations
            class_attribute :_ransack_can_autocomplete
            self._ransackers ||= {}
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

        def ransackable_associations(auth_object = nil)
          all_associations = reflect_on_all_associations.map {|a| a.name.to_s}
          if self._ransackable_associations.any?
            # Return intersection of all associations, and associations defined on the model
            all_associations & self._ransackable_associations
          else
            all_associations
          end
        end

      end
    end
  end
end
