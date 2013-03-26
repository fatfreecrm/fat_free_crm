# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# Custom fields need to be loaded so they register their availability
#------------------------------------------------------------------------------
custom_field_path = File.join(File.dirname(__FILE__), '..', '..', 'app', 'models', 'fields', 'custom_field_*')
Dir[custom_field_path].each {|f| require f}
