require "recap/ruby"

server "gofreerange.com", :app
set :application, "sauron"

set :repository,  "git@github.com:freerange/sauron.git"
set :branch, "master"

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
    as_app "#{whenever_command} #{whenever_update_flags}"
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab, :roles => :app do
    as_app "#{whenever_command} #{whenever_clear_flags}"
  end
end

namespace :database do
  namespace :migrate do
    desc "Run database migrations only if new migrations exist"
    task :if_changed do
      if deployed_file_changed?('db')
        top.database.migrate.default
      end
    end

    desc "Run database migrations"
    task :default do
      as_app "bundle exec rake db:migrate"
    end
  end
end

after "deploy:update_code", "database:migrate:if_changed"