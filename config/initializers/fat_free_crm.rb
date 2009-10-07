require "fat_free_crm"

#---------------------------------------------------------------------
ActiveRecord::Base.class_eval do
  include FatFreeCRM::Permissions
end

#---------------------------------------------------------------------
Sass::Plugin.options[:template_location] = File.join(RAILS_ROOT, "app/stylesheets")
Sass::Plugin.options[:css_location] = File.join(RAILS_ROOT, "public/stylesheets")

#---------------------------------------------------------------------
Date::DATE_FORMATS[:mmddyyyy] = "%m/%d/%Y"
Date::DATE_FORMATS[:mmdd] = "%b %e"
Date::DATE_FORMATS[:mmddyy] = "%b %e, %Y"
Time::DATE_FORMATS[:mmddhhss] = "%b %e at %l:%M%p"

#---------------------------------------------------------------------
WillPaginate::ViewHelpers.pagination_options[:renderer] = "AjaxWillPaginate"
