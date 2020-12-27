# Extend original ransack adapter first
require 'ransack/constants'
require 'ransack/adapters/active_record'

require 'ransack_ui/adapters/active_record/base'
ActiveRecord::Base.extend RansackUI::Adapters::ActiveRecord::Base
