class Person < ActiveRecord::Base
  simple_column_search :first_name, :last_name, :alias

  simple_column_search :first_name, :name => :search_first_name_default_match

  simple_column_search :first_name, :name => :search_first_name_exact, :match => :exact
  simple_column_search :first_name, :name => :search_first_name_start, :match => :start
  simple_column_search :first_name, :name => :search_first_name_middle, :match => :middle
  simple_column_search :first_name, :name => :search_first_name_end, :match => :end

  simple_column_search :first_name, :last_name, :name => :search_escape_query, :match => :exact, :escape => lambda { |q| q.sub('ile', 'ille').strip }
  simple_column_search :first_name, :last_name, :name => :search_match_lambda, :match => lambda { |c| c == :last_name ? :exact : :start }
end