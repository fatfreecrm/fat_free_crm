require 'rubygems'

gem 'rspec'
require 'spec'

%w[activesupport activerecord actionpack].each do |lib|
  gem lib
  require lib
end

require 'action_controller'
require 'active_record/observer'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'user_stamp'

UserStampSweeper.instance

class User
  attr_accessor :id
  
  def initialize(id);
    @id = id
  end
end
