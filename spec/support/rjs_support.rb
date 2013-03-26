# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
RSpec::Rails::ViewExampleGroup::ExampleMethods.module_eval do
  # Ruby 1.8.x doesnt support alias_method_chain with blocks,
  # so we are just overwriting the whole method.
  def render(options={}, local_assigns={}, &block)
    options = {:template => _default_file_to_render} if Hash === options and options.empty?
    super(options, local_assigns, &block)
    @response = mock(:body => rendered)
  end
end
