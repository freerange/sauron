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