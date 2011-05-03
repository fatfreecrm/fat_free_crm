module FatFreeCRM
  module Taggable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def is_taggable
        acts_as_taggable
        unless included_modules.include?(InstanceMethods)
          include FatFreeCRM::Taggable::InstanceMethods
        end
      end
    end

    module InstanceMethods
      def add_tag(tags_to_add)
        tag_list.add(tags_to_add, :parse => true)
        save
      end

      def delete_tag(tag_to_delete)
        tag_list.remove(tag_to_delete)
        save
      end
    end
  end
end
