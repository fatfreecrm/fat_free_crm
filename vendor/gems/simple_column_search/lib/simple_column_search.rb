require 'rubygems'
require 'active_record'

module SimpleColumnSearch
  class InvalidMatcher < StandardError; end

  # Adds a Model.search('term1 term2') method that searches across SEARCH_COLUMNS
  # for ANDed TERMS ORed across columns.
  #
  #  class User
  #    simple_column_search :first_name, :last_name
  #  end
  #
  #  User.search('elijah')          # => anyone with first or last name elijah
  #  User.search('miller')          # => anyone with first or last name miller
  #  User.search('elijah miller')
  #    # => anyone with first or last name elijah AND
  #    #    anyone with first or last name miller
  def simple_column_search(*args)
    options = args.extract_options!
    columns = args

    options[:match] ||= :start
    options[:name] ||= 'search'

    unless options[:match].is_a?(Proc) || [ :start, :middle, :end, :exact ].include?(options[:match])
      raise InvalidMatcher, "Unexpected match type: #{options[:match].inspect}"
    end

    # PostgreSQL LIKE is case-sensitive, use ILIKE for case-insensitive
    like = connection.adapter_name == "PostgreSQL" ? "ILIKE" : "LIKE"
    # Determine if ActiveRecord 3 or ActiveRecord 2.3 - probaly beter way to do it!
    if self.respond_to?(:where)
      scope options[:name], lambda { |terms|
        terms = options[:escape].call(terms) if options[:escape]
        conditions = terms.split.inject(where(nil)) do |acc, term|
          patterns = build_simple_column_patterns(columns, options[:match], term)
          acc.where(columns.map { |column| "#{table_name}.#{column} #{like} ?" }.join(' OR '), *patterns)
        end
      }
    else
      named_scope options[:name], lambda { |terms|
        terms = options[:escape].call(terms) if options[:escape]
        conditions = terms.split.inject(nil) do |acc, term|
          patterns = build_simple_column_patterns(columns, options[:match], term)
          merge_conditions acc, [ columns.map { |column| "#{table_name}.#{column} #{like} ?" }.join(' OR '), *patterns ]
        end
        { :conditions => conditions }
      }
    end
  end

  private
  def build_simple_column_patterns(columns, match, term)
    columns.map do |column|
      get_simple_column_pattern(match.is_a?(Proc) ? match.call(column) : match, term)
    end
  end

  def get_simple_column_pattern(match, term)
    case(match)
    when :exact
      term
    when :start
      term + '%'
    when :middle
      '%' + term + '%'
    when :end
      '%' + term
    else
      raise InvalidMatcher, "Unexpected match type: #{match.inspect}"
    end
  end
end

ActiveRecord::Base.extend(SimpleColumnSearch)