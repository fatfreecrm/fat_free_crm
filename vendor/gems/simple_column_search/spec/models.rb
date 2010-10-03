class Person < ActiveRecord::Base
  simple_column_search :first_name, :last_name, :alias

  simple_column_search :first_name, :name => :search_first_name_default_match

  simple_column_search :first_name, :name => :search_first_name_exact, :match => :exact
  simple_column_search :first_name, :name => :search_first_name_start, :match => :start
  simple_column_search :first_name, :name => :search_first_name_middle, :match => :middle
  simple_column_search :first_name, :name => :search_first_name_end, :match => :end
end