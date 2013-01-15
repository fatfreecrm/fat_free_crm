require 'delayed_job'
Delayed::Worker.max_attempts = 1
Delayed::Worker.backend = :active_record