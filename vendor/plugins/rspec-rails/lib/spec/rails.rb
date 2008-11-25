silence_warnings { RAILS_ENV = "test" }

require_dependency 'application'
require 'action_controller/test_process'
require 'action_controller/integration'
require 'active_record/fixtures' if defined?(ActiveRecord::Base)
require 'test/unit'

require 'spec'

require 'spec/rails/matchers'
require 'spec/rails/mocks'
require 'spec/rails/example'
require 'spec/rails/extensions'
require 'spec/rails/interop/testcase'