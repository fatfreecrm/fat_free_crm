module Searchlogic
  # == Searchlogic ActiveRecord
  #
  # Hooks into ActiveRecord to add all of the searchlogic functionality into your models. Only uses what is publically available, doesn't dig into internals, and
  # searchlogic only gets involved when needed.
  module ActiveRecord
    # = Searchlogic ActiveRecord Base
    # Adds in base level functionality to ActiveRecord
    module Base
      # This is an alias method chain. It hook into ActiveRecord's "calculate" method and checks to see if Searchlogic should get involved.
      def calculate_with_searchlogic(*args)
        options = args.extract_options!
        options = filter_options_with_searchlogic(options, false)
        args << options
        calculate_without_searchlogic(*args)
      end
      
      # This is an alias method chain. It hooks into ActiveRecord's "find" method and checks to see if Searchlogic should get involved.
      def find_with_searchlogic(*args)
        options = args.extract_options!
        options = filter_options_with_searchlogic(options)
        args << options
        find_without_searchlogic(*args)
      end
      
      # This is an alias method chain. It hooks into ActiveRecord's scopes and checks to see if Searchlogic should get involved. Allowing you to use all of Searchlogics conditions and tools
      # in scopes as well.
      #
      # === Examples
      #
      # Named scopes:
      #
      #   named_scope :top_expensive, :conditions => {:total_gt => 1_000_000}, :per_page => 10
      #   named_scope :top_expensive_ordered, :conditions => {:total_gt => 1_000_000}, :per_page => 10, :order_by => {:user => :first_name}
      #
      # Good ole' regular scopes:
      #
      #   with_scope(:find => {:conditions => {:total_gt => 1_000_000}, :per_page => 10}) do
      #     find(:all)
      #   end
      #
      #   with_scope(:find => {:conditions => {:total_gt => 1_000_000}, :per_page => 10}) do
      #     build_search
      #   end
      def with_scope_with_searchlogic(method_scoping = {}, action = :merge, &block)
        method_scoping[:find] = filter_options_with_searchlogic(method_scoping[:find]) if method_scoping[:find]
        with_scope_without_searchlogic(method_scoping, action, &block)
      end
      
      # This is a special method that Searchlogic adds in. It returns a new search object on the model. So you can search via an object.
      #
      # <b>This method is "protected". Meaning it checks the passed options for SQL injections. So trying to write raw SQL in *any* of the option will result in a raised exception. It's safe to pass a params object when instantiating.</b>
      #
      # This method has an alias "new_search"
      #
      # === Examples
      #
      #   search = User.new_search
      #   search.conditions.first_name_contains = "Ben"
      #   search.per_page = 20
      #   search.page = 2
      #   search.order_by = {:user_group => :name}
      #   search.all # can call any search method: first, find(:all), find(:first), sum("id"), etc...
      def build_search(options = {}, &block)
        search = searchlogic_search
        search.protect = true
        search.options = options
        yield search if block_given?
        search
      end
      
      # See build_search. This is the same method but *without* protection. Do *NOT* pass in a params object to this method.
      #
      # This also has an alias "new_search!"
      def build_search!(options = {}, &block)
        search = searchlogic_search(options)
        yield search if block_given?
        search
      end
      
      # Similar to ActiveRecord's attr_protected, but for conditions. It will block any conditions in this array that are being mass assigned. Mass assignments are:
      #
      # === Examples
      #
      # search = User.new_search(:conditions => {:first_name_like => "Ben", :email_contains => "binarylogic.com"})
      # search.options = {:conditions => {:first_name_like => "Ben", :email_contains => "binarylogic.com"}}
      #
      # If first_name_like is in the list of conditions_protected then it will be removed from the hash.
      def conditions_protected(*conditions)
        write_inheritable_attribute(:conditions_protected, Set.new(conditions.map(&:to_s)) + (protected_conditions || []))
      end

      def protected_conditions # :nodoc:
        read_inheritable_attribute(:conditions_protected)
      end
      
      # This is the reverse of conditions_protected. You can specify conditions here and *only* these conditions will be allowed in mass assignment. Any condition not specified here will be blocked.
      def conditions_accessible(*conditions)
        write_inheritable_attribute(:conditions_accessible, Set.new(conditions.map(&:to_s)) + (accessible_conditions || []))
      end

      def accessible_conditions # :nodoc:
        read_inheritable_attribute(:conditions_accessible)
      end
    
      private
        def filter_options_with_searchlogic(options = {}, searching = true)
          return options unless Searchlogic::Search::Base.needed?(self, options)
          search = Searchlogic::Search::Base.create_virtual_class(self).new # call explicitly to avoid merging the scopes into the search
          search.acting_as_filter = true
          search.scope = scope(:find)
          conditions = options.delete(:conditions) || options.delete("conditions") || {}
          if conditions
            case conditions
            when Hash
              conditions.each { |condition, value| search.conditions.send("#{condition}=", value) } # explicitly call to enforce blanks
            else
              search.conditions = conditions
            end
          end
          search.options = options
          search.sanitize(searching)
        end
        
        def searchlogic_search(options = {})
          scope = {}
          current_scope = scope(:find) && scope(:find).deep_dup
          if current_scope
            [:conditions, :include, :joins].each do |option|
              value = current_scope.delete(option)
              next if value.blank?
              scope[option] = value
            end
            
            # Delete nil values in the scope, for some reason habtm relationships like to pass :limit => nil
            new_scope = {}
            current_scope.each { |k, v| new_scope[k] = v unless v.nil? }
            current_scope = new_scope
          end
          search = Searchlogic::Search::Base.create_virtual_class(self).new
          search.scope = scope
          search.options = current_scope
          search.options = options
          search
        end
    end
  end
end

ActiveRecord::Base.send(:extend, Searchlogic::ActiveRecord::Base)

module ActiveRecord #:nodoc: all
  class Base
    class << self
      alias_method_chain :calculate, :searchlogic
      alias_method_chain :find, :searchlogic
      alias_method_chain :with_scope, :searchlogic
      alias_method :new_search, :build_search
      alias_method :new_search!, :build_search!
      
      def valid_find_options
        VALID_FIND_OPTIONS
      end
      
      def valid_calculations_options
        Calculations::CALCULATIONS_OPTIONS
      end
      
      private
        # This is copied over from 2 different versions of ActiveRecord. I have to do this in order to preserve the "auto joins"
        # as symbols. Keeping them as symbols allows ActiveRecord to merge them properly. The problem is when they conflict with includes.
        # Includes add joins also, and they add them before joins do. So if they already added them skip them. Now you can do queries like:
        #
        # User.all(:joins => {:orders => :line_items}, :include => :orders)
        #
        # Where as before, the only way to get the above query to work would be to include line_items also, which is not neccessarily what you want.
        def add_joins!(sql, options_or_joins, scope = :auto) # :nodoc:
          code_type = (respond_to?(:array_of_strings?, true) && :array_of_strings) || (respond_to?(:merge_joins, true) && :merge_joins)

          case code_type
          when :array_of_strings, :merge_joins
            joins = options_or_joins
            scope = scope(:find) if :auto == scope
            merged_joins = scope && scope[:joins] && joins ? merge_joins(scope[:joins], joins) : (joins || scope && scope[:joins])
            case merged_joins
            when Symbol, Hash, Array
              if code_type == :array_of_strings && array_of_strings?(merged_joins)
                merged_joins.each { |merged_join| sql << " #{merged_join} " unless sql.include?(merged_join) }
              else
                join_dependency = ActiveRecord::Associations::ClassMethods::InnerJoinDependency.new(self, merged_joins, nil)
                join_dependency.join_associations.each do |assoc|
                  join_sql = assoc.association_join
                  sql << " #{join_sql} " unless sql.include?(join_sql)
                end
              end
            when String
              sql << " #{merged_joins} " if merged_joins && !sql.include?(merged_joins)
            end
          else
            options = options_or_joins
            scope = scope(:find) if :auto == scope
            [(scope && scope[:joins]), options[:joins]].each do |join|
              case join
              when Symbol, Hash, Array
                join_dependency = ActiveRecord::Associations::ClassMethods::InnerJoinDependency.new(self, join, nil)
                join_dependency.join_associations.each do |assoc|
                  join_sql = assoc.association_join
                  sql << " #{join_sql} " unless sql.include?(join_sql)
                end
              else
                sql << " #{join} " if join && !sql.include?(join)
              end
            end
          end
        end
    end
  end
end