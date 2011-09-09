require "tomafro/deploy"

server "gofreerange.com", :app

set :application, "sauron"
set :repository,  "git@github.com:freerange/sauron.git"