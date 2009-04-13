require "fat_free_crm"

#---------------------------------------------------------------------
class ActiveSupport::BufferedLogger
  def p(*args)
    info "\033[1;37;40m\n\n" << args.join(" ") << "\033[0m\n\n\n"
  end
end

#---------------------------------------------------------------------
Sass::Plugin.options[:template_location] = File.join(RAILS_ROOT, "app/stylesheets")
Sass::Plugin.options[:css_location] = File.join(RAILS_ROOT, "public/stylesheets")

#---------------------------------------------------------------------
Date::DATE_FORMATS[:mmddyyyy] = "%m/%d/%Y"
Date::DATE_FORMATS[:mmdd] = "%b %e"
Time::DATE_FORMATS[:mmddhhss] = "%b %e at %l:%M%p"
