#require 'delayed_job'
Delayed::Worker.max_attempts = 1
#Delayed::Worker.sleep_delay = 60
Delayed::Worker.backend = :active_record
Delayed::Worker.logger = 
  ActiveSupport::BufferedLogger.new("log/#{Rails.env}_delayed_jobs.log", Rails.logger.level)
Delayed::Worker.logger.auto_flushing = 1
Delayed::Worker.destroy_failed_jobs = false