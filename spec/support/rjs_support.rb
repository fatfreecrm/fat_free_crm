RSpec::Rails::ViewExampleGroup::ExampleMethods.module_eval do
  # Ruby 1.8.x doesnt support alias_method_chain with blocks,
  # so we are just overwriting the whole method.
  def render(options={}, local_assigns={}, &block)
    options = {:template => _default_file_to_render} if Hash === options and options.empty?
    super(options, local_assigns, &block)
    @response = mock(:body => rendered)
  end
end