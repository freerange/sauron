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

# Learn more: http://github.com/javan/whenever

env :MAILTO, 'everyone@gofreerange.com'

set :job_template, nil
job_type :lockrun_rake, "/usr/local/bin/lockrun --lockfile=:lockfile.lockrun --quiet -- bash -l -c 'cd :path && RAILS_ENV=:environment nice rake :task :output'"

every 1.minute do
  # lockrun_rake "mail:import", lockfile: 'mail-import'
end