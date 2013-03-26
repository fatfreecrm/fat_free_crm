# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# Plugin dependencies
Dir.glob(File.join(File.dirname(__FILE__), '..', 'plugins', '**')).each do |plugin_dir|
  # Add 'plugin/lib' to $LOAD_PATH
  $:.unshift File.expand_path(File.join(plugin_dir, 'lib'))
  require File.basename(plugin_dir)      # require 'plugin'
  require File.join(plugin_dir, 'init')  # require 'plugin/init'
end
