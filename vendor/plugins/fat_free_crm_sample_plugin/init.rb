RAILS_DEFAULT_LOGGER.info ">> Adding sample Fat Free CRM plugin..."

FatFreeCRM::Plugin. << :sample_plugin do
  name "Sample Fat Free CRM Plugin"
  description "Sample 'do-nothing' plugin to test and demonstrate the concepts."
  author "Michael Dvorkin"
  version "1.0"
end

RAILS_DEFAULT_LOGGER.info ">> Fat Free CRM Plugins:\n" + FatFreeCRM::Plugin.list.inspect

# Let the magic begin! ;-)
#----------------------------------------------------------------------------
class HomeCallback < FatFreeCRM::Callback::Base

  # home/index view hook.
  #----------------------------------------------------------------------------
  def home_view(view, context = {})
    view.logger.info "view: " + view.class.to_s
    "home_view: hook parameters: " + context.inspect
  end

  # home/index controller hook.
  #----------------------------------------------------------------------------
  def home_controller(controller, context = {})
    controller.logger.info "controller: " + controller.controller_name
    controller.logger.info "action: " + controller.action_name
    controller.logger.info "hello: " + controller.instance_variable_get("@hello")
    controller.logger.info "home_controller: hook parameters: " + context.inspect
  end

  # home controller before_filter hook.
  #----------------------------------------------------------------------------
  def home_before_filter(controller, context = {})
    controller.logger.info "controller: " + controller.controller_name
    controller.logger.info "action: " + controller.action_name
    controller.logger.info "params: " + controller.params.inspect
    controller.logger.info "home_before_filter: hook parameters: " + context.inspect
  end

end