require "tomafro/deploy"
require "tomafro/deploy/foreman"
require "tomafro/deploy/env"

server "gofreerange.com", :app

set :application, "sauron"
set :repository,  "git@github.com:freerange/sauron.git"

before "deploy:update_code", "whenever:clear_crontab"
after "deploy:tag", "whenever:update_crontab"
after "deploy:rollback", "whenever:update_crontab"

set :whenever_command, "bundle exec whenever"

namespace :whenever do
  desc "Update application's crontab entries using Whenever"
  task :update_crontab, :roles => :app do
    as_app "cd #{deploy_to} && #{whenever_command} --update-crontab #{application}"
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab, :roles => :app do
    as_app "cd #{deploy_to} && #{whenever_command} --clear-crontab #{application}"
  end
end

after "deploy:tag", "create_mongo_indexes"
task :create_mongo_indexes do
  as_app "cd #{deploy_to} && bundle exec rake db:mongoid:create_indexes"
end