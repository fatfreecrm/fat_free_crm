# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  def render_class_and_action(note = nil, options={})
    text = "rendered in #{self.class.name}##{params[:action]}"
    text += " (#{note})" unless note.nil?
    render options.update(:text => text)
  end
  
  def rescue_action(e) raise e end;
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b955354e438fc4ba070083505af94518'
end
