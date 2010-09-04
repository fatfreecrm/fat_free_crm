require "factory_girl"
require "#{::Rails.root}/spec/factories"

# Add event.simulate.js to cucumber environment,
# so that we can simulate events such as mouseclicks.
class EventSimulateViewHooks < FatFreeCRM::Callback::Base

  def javascript_includes(view, context = {})
    view.javascript_include_tag "event.simulate.js"
  end

end
