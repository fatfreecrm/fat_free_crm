Spork.prefork do
  require "factory_girl"
  require RAILS_ROOT + "/spec/factories"
end

Spork.each_run do
end


# Add event.simulate.js to cucumber environment,
# so that we can simulate events such as mouseclicks.
class EventSimulateViewHooks < FatFreeCRM::Callback::Base

  def javascript_includes(view, context = {})
    view.javascript_include_tag "event.simulate.js"
  end

end


# Cancel any activity logging for Comment model
Comment.class_eval do
  def log_activity; end
end

