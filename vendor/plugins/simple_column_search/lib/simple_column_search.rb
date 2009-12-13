require 'rubygems'
require 'activerecord'

module SimpleColumnSearch
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

    # PostgreSQL LIKE is case-sensitive, use ILIKE for case-insensitive
    like = connection.adapter_name == "PostgreSQL" ? "ILIKE" : "LIKE"

    named_scope options[:name], lambda { |terms|
      terms = options[:escape].call(terms) if options[:escape]    
      conditions = terms.split.inject(nil) do |acc, term|
        pattern = 
          case(options[:match])
          when :exact
            term
          when :start
            term + '%'
          when :middle
            '%' + term + '%'
          when :end
            '%' + term
          else
            raise "Unexpected match type: #{options[:match]}"
          end
        merge_conditions  acc, [columns.collect { |column| "#{table_name}.#{column} #{like} :pattern" }.join(' OR '), { :pattern => pattern }]
      end
    
      { :conditions => conditions }
    }
  end
  
end
