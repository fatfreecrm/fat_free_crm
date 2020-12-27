require "ransack_ui/version"
require "ransack_ui/rails/engine"
require "ransack_chronic"

# Require ransack overrides
require 'ransack_ui/adapters/active_record'
Dir.glob(File.expand_path('../ransack_ui/ransack_overrides/**/*.rb', __FILE__)) {|f| require f }

require "ransack"