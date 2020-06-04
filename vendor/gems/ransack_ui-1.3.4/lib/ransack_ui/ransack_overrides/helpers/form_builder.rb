require 'ransack/helpers/form_builder'

module Ransack
  module Helpers
    FormBuilder.class_eval do
      cattr_accessor :cached_searchable_attributes_for_base
      self.cached_searchable_attributes_for_base = {}

      def attribute_select(options = {}, html_options = {})
        raise ArgumentError, "attribute_select must be called inside a search FormBuilder!" unless object.respond_to?(:context)
        options[:include_blank] = true unless options.has_key?(:include_blank)

        # Set default associations set on model with 'has_ransackable_associations'
        if options[:associations].nil?
          options[:associations] = object.context.klass.ransackable_associations
        end

        bases = [''] + association_array(options[:associations])
        if bases.size > 1
          @template.select(
            @object_name, :name,
            @template.grouped_options_for_select(attribute_collection_for_bases(bases), object.name),
            objectify_options(options), @default_options.merge(html_options)
          )
        else
          @template.select(
            @object_name, :name, attribute_collection_for_base(bases.first),
            objectify_options(options), @default_options.merge(html_options)
          )
        end
      end

      def sort_select(options = {}, html_options = {})
        raise ArgumentError, "sort_select must be called inside a search FormBuilder!" unless object.respond_to?(:context)
        options[:include_blank] = true unless options.has_key?(:include_blank)
        bases = [''] + association_array(options[:associations])
        if bases.size > 1
          @template.select(
            @object_name, :name,
            @template.grouped_options_for_select(attribute_collection_for_bases(bases), object.name),
            objectify_options(options), @default_options.merge({:class => 'ransack_sort'}).merge(html_options)
          ) + @template.collection_select(
            @object_name, :dir, [['asc', object.translate('asc')], ['desc', object.translate('desc')]], :first, :last,
            objectify_options(options.except(:include_blank)), @default_options.merge({:class => 'ransack_sort_order'}).merge(html_options)
          )
        else
          # searchable_attributes now returns [c, type]
          collection = object.context.searchable_attributes(bases.first).map do |c, type|
            [
              attr_from_base_and_column(bases.first, c),
              Translate.attribute(attr_from_base_and_column(bases.first, c), :context => object.context)
            ]
          end
          @template.collection_select(
            @object_name, :name, collection, :first, :last,
            objectify_options(options), @default_options.merge({:class => 'ransack_sort'}).merge(html_options)
          ) + @template.collection_select(
            @object_name, :dir, [['asc', object.translate('asc')], ['desc', object.translate('desc')]], :first, :last,
            objectify_options(options.except(:include_blank)), @default_options.merge({:class => 'ransack_sort_order'}).merge(html_options)
          )
        end
      end

      def labels_for_value_fields
        labels = {}

        object.groupings.each do |grouping|
          grouping.conditions.each do |condition|
            condition.values.each do |value|
              # If value is present, and the attribute is an association,
              # load the selected record and include the record name as a data attribute
              if value.value.present?
                condition_attributes = condition.attributes
                if condition_attributes.any?
                  attribute = condition_attributes.first.name
                  klass_name = foreign_klass_for_attribute(attribute)

                  if klass_name
                    klass = klass_name.constantize

                    value_object = klass.find_by_id(value.value)
                    if value_object
                      labels[attribute] ||= {}

                      if value_object.respond_to? :full_name
                        labels[attribute][value.value] = value_object.full_name
                      elsif value_object.respond_to? :name
                        labels[attribute][value.value] = value_object.name
                      end
                    end
                  end
                end
              end
            end
          end
        end

        labels
      end


      def predicate_keys(options)
        keys = options[:compounds] ? Predicate.names : Predicate.names.reject {|k| k.match(/_(any|all)$/)}
        if only = options[:only]
          if only.respond_to? :call
            keys = keys.select {|k| only.call(k)}
          else
            only = Array.wrap(only).map(&:to_s)
            # Create compounds hash, e.g. {"eq" => ["eq", "eq_any", "eq_all"], "blank" => ["blank"]}
            key_groups = keys.inject(Hash.new([])){ |h,k| h[k.sub(/_(any|all)$/, '')] += [k]; h }
            # Order compounds hash by 'only' keys
            keys = only.map {|k| key_groups[k] }.flatten.compact
          end
        end
        keys
      end

      def predicate_select(options = {}, html_options = {})
        options = Ransack.options[:default_predicates] || {} if options.blank?

        options[:compounds] = true if options[:compounds].nil?
        keys = predicate_keys(options)
        # If condition is newly built with build_condition(),
        # then replace the default predicate with the first in the ordered list
        @object.predicate_name = keys.first if @object.default?
        @template.collection_select(
          @object_name, :p, keys.map {|k| [k, Translate.predicate(k)]}, :first, :last,
          objectify_options(options), @default_options.merge(html_options)
        )
      end

      def attribute_collection_for_bases(bases)
        bases.map do |base|
          if collection = attribute_collection_for_base(base)
            [
              Translate.association(base, :context => object.context),
              collection
            ]
          end
        end.compact
      end

      def attribute_collection_for_base(base)
        klass = object.context.traverse(base)
        ajax_options = Ransack.options[:ajax_options] || {}

        # Detect any inclusion validators to build list of options for a column
        column_select_options = klass.validators.each_with_object({}) do |v, hash|
          if v.is_a? ActiveModel::Validations::InclusionValidator
            v.attributes.each do |a|
              # Try to translate options from activerecord.attribute_options.<model>.<attribute>
              inclusions = v.send(:delimiter)
              inclusions = inclusions.call if inclusions.respond_to?(:call) # handle lambda
              hash[a.to_s] = inclusions.each_with_object({}) do |o, options|
                options[o.to_s] = I18n.translate("activerecord.attribute_options.#{klass.to_s.downcase}.#{a}.#{o}", :default => o.to_s.titleize)
              end
            end
          end
        end

        if klass.respond_to?(:ransack_column_select_options)
          column_select_options.merge!(klass.ransack_column_select_options)
        end

        searchable_attributes_for_base(base).map do |attribute_data|
          column = attribute_data[:column]

          html_options = {}

          # Add column type as data attribute
          html_options[:'data-type'] = attribute_data[:type]
          # Set 'base' attribute if attribute is on base model
          html_options[:'data-root-model'] = true if base.blank?

          # Set column options if detected from inclusion validator
          if column_select_options[column]
            # Format options as an array of hashes with id and text columns, for Select2
            html_options[:'data-select-options'] = column_select_options[column].map {|id, text|
              {:id => id, :text => text}
            }.to_json
          end

          foreign_klass = attribute_data[:foreign_klass]

          if foreign_klass
            # If field is a foreign key, set up 'data-ajax-*' attributes for auto-complete
            controller = ActiveSupport::Inflector::tableize(foreign_klass.to_s)
            html_options[:'data-ajax-entity'] = I18n.translate(controller, :default => controller)
            if ajax_options[:url]
              html_options[:'data-ajax-url'] = ajax_options[:url].sub(':controller', controller)
            else
              html_options[:'data-ajax-url'] = "/#{controller}.json"
            end
            html_options[:'data-ajax-type'] = ajax_options[:type] || 'GET'
            html_options[:'data-ajax-key']  = ajax_options[:key]  || 'query'
          end

          [
            attribute_data[:label],
            attribute_data[:attribute],
            html_options
          ]
        end
      rescue UntraversableAssociationError => e
        nil
      end


      private

      def searchable_attributes_for_base(base)
        cache_prefix = object.context.klass.table_name
        cache_key = base.blank? ? cache_prefix : [cache_prefix, base].join('_')

        self.class.cached_searchable_attributes_for_base[cache_key] ||= object.context.searchable_attributes(base).map do |column, type|
          klass = object.context.traverse(base)
          foreign_keys = klass.reflect_on_all_associations.select(&:belongs_to?).
                           each_with_object({}) {|r, h| h[r.foreign_key.to_sym] = r.class_name }

          # Don't show 'id' column for base model
          next nil if base.blank? && column == 'id'

          attribute = attr_from_base_and_column(base, column)
          attribute_label = Translate.attribute(attribute, :context => object.context)

          # Set model name as label for 'id' column on that model's table.
          if column == 'id'
            foreign_klass = object.context.traverse(base).model_name
            # Check that model can autocomplete. If not, skip this id column.
            next nil unless ActiveSupport::Inflector::constantize(foreign_klass.to_s)._ransack_can_autocomplete

            attribute_label = I18n.translate(foreign_klass, :default => foreign_klass)
          else
            foreign_klass = foreign_keys[column.to_sym]
          end

          attribute_data = {
            label: attribute_label,
            type: type,
            column: column,
            attribute: attribute
          }
          attribute_data[:foreign_klass] = foreign_klass if foreign_klass
          attribute_data
        end.compact
      end

      def foreign_klass_for_attribute(attribute)
        associations = object.context.klass.ransackable_associations
        bases = [''] + association_array(associations)

        bases.each do |base|
          searchable_attributes_for_base(base).each do |attribute_data|
            if attribute == attribute_data[:attribute]
              return attribute_data[:foreign_klass]
            end
          end
        end
      end
    end
  end
end
