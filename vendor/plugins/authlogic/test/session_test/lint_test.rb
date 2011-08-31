require File.dirname(__FILE__) + '/../test_helper.rb'

class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests
 
  def setup
    @model = UserSession.new
  end
end