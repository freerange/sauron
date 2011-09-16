require "tomafro/deploy"

server "gofreerange.com", :app

set :application, "sauron"
set :repository,  "git@github.com:freerange/sauron.git"
set :default_environment, {
  "PATH" => "/var/rubies/1.9.2-p290/bin:$PATH"
}

task :update do
  run "cd #{deploy_to} && script/update"
end

task :add_account do
  run "cd #{deploy_to} && script/add_account '#{email}' '#{password}'"
end

set :whenever_command, "bundle exec whenever"
set(:whenever_identifier)   { application }
set(:whenever_update_flags) { "--update-crontab #{whenever_identifier} -u #{application_user}" }
set(:whenever_clear_flags)  { "--clear-crontab #{whenever_identifier} -u #{application_user}" }

before "deploy:update_code", "whenever:clear_crontab"
after "deploy:tag", "whenever:update_crontab"
after "deploy:rollback", "whenever:update_crontab"

namespace :whenever do
  desc "Update application's crontab entries using Whenever"
  task :update_crontab, :roles => :app do
    run "cd #{deploy_to} && sudo env PATH=$PATH #{whenever_command} #{whenever_update_flags}"
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab, :roles => :app do
    run "cd #{deploy_to} && sudo env PATH=$PATH #{whenever_command} #{whenever_clear_flags}"
  end
end

after "deploy:tag", "create_mongo_indexes"
task :create_mongo_indexes do
  run "cd #{deploy_to} && RAILS_ENV=production bundle exec rake db:mongoid:create_indexes"
end