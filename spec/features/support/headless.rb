# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
#
# Drives the browser in 'headless' mode if required.
# Useful for CI and travis tests
#

if ENV['HEADLESS'] == 'true' || ENV["CI"] == "true"
  require 'headless'
  headless = Headless.new
  headless.start
  HEADLESS_DISPLAY = ":#{headless.display}"
  puts "Running in Headless mode. Display #{HEADLESS_DISPLAY}"
end
