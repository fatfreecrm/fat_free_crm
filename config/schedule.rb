# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
set :output, 'log/rake_tasks.log'

every "0 9-18 * * *" do
  rake "ffcrm:registrations:sync"
end

every 10.minutes do
  rake "ffcrm:dropbox:run"
end

every 10.minutes do
  rake "ffcrm:comment_replies:run"
end

every 6.hours do
  command "backup perform -t my_backup", :output => '/var/www/esCRM/current/log/backup.log'
end

# Learn more: http://github.com/javan/whenever
