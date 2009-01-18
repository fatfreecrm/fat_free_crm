RAILS_DEFAULT_LOGGER.info ">> Adding sample Fat Free CRM plugin..."

FatFreeCRM::Plugin. << :sample_plugin do
  name "Sample Fat Free CRM Plugin"
  description "Sample 'do-nothing' plugin to test and demonstrate the concept."
  author "Michael Dvorkin"
  version "1.0"
end

RAILS_DEFAULT_LOGGER.info ">> Fat Free CRM Plugins:\n" + FatFreeCRM::Plugin.list.inspect