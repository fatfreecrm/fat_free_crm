#----------------------------------------------------------------------------
def set_current_tab(tab)
  controller.session[:current_tab] = tab
end

#----------------------------------------------------------------------------
def stub_task(view)
  if view == "completed"
    assigns[:task] = Factory(:task, :completed_at => Time.now - 1.minute)
  elsif view == "assigned"
    assigns[:task] = Factory(:task, :assignee => Factory(:user))
  else
    assigns[:task] = Factory(:task)
  end
end

#----------------------------------------------------------------------------
def stub_task_total(view = "pending")
  settings = (view == "completed" ? Setting.task_completed : Setting.task_bucket)
  settings.inject({ :all => 0 }) { |hash, key| hash[key] = 1; hash }
end

# Get current server timezone and set it (see rake time:zones:local for details).
#----------------------------------------------------------------------------
def set_timezone
  offset = [ Time.now.beginning_of_year.utc_offset, Time.now.beginning_of_year.change(:month => 7).utc_offset ].min
  offset *= 3600 if offset.abs < 13
  Time.zone = ActiveSupport::TimeZone.all.select { |zone| zone.utc_offset == offset }.first
end

# Adjusts current timezone by given offset (in seconds).
#----------------------------------------------------------------------------
def adjust_timezone(offset)
  if offset
    ActiveSupport::TimeZone[offset]
    adjusted_time = Time.now + offset.seconds
    Time.stub(:now).and_return(adjusted_time)
  end
end

# Load default settings from config/settings.yml file.
#----------------------------------------------------------------------------
def load_default_settings
  # Truncate settings so that we always start with empty table.
  if ActiveRecord::Base.connection.adapter_name.downcase == "sqlite"
    ActiveRecord::Base.connection.execute("DELETE FROM settings")
  else # mysql and postgres
    ActiveRecord::Base.connection.execute("TRUNCATE settings")
  end

  settings = YAML.load_file("#{::Rails.root}/config/settings.yml")
  settings.keys.each do |key|
    Factory.define key.to_sym, :parent => :setting do |factory|
      factory.name key.to_s
      factory.default_value Base64.encode64(Marshal.dump(settings[key]))
    end
    Factory(key.to_sym) # <--- That's where the data gets loaded.
  end
end

