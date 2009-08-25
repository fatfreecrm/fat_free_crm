module ApplicationHelper

  def self.included(base)
    base.class_eval do
      alias_method_chain :tabs, :issues
    end
  end

  def tabs_with_issues
    logger.p "tabs_with_issues"
    tabs = tabs_without_issues # Call origial :tabs method from helpers/application_helper.rb
    if_current = (@current_tab == :issues || @current_tab == :issues_path)
    tabs << { :active => if_current, :url => { :controller => issues_path }, :text => "Issues" }
  end

end
