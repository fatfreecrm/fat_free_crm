module FatFreeCRM
  module SearchableAndFilterable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def is_searchable_and_filterable
        # Search and filter by user, tags, query and status
        #----------------------------------------------------------------------------
        def self.search_and_filter(options)
          user, filtered, query, tags = options[:user], options[:filter], options[:query], options[:tags]
          order = user.preference[:"#{self.name.pluralize}_sort_by"] || self.sort_by

          searched_and_filtered = self
          searched_and_filtered = my(:user => user, :order => order) if respond_to?(:my)
          searched_and_filtered = searched_and_filtered.only(filtered.split(',')) if respond_to?(:only) && filtered.present?
          searched_and_filtered = searched_and_filtered.search(query) if respond_to?(:search) && query.present?
          searched_and_filtered = searched_and_filtered.tagged_with(tags) if respond_to?(:tagged_with) && tags.present?
          searched_and_filtered
        end
      end
    end
  end
end
