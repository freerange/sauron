namespace :messages do
  desc "Fetch all messages for all credentials in TEAM/PASSWORDS"
  task :import => :environment do
    TeamMessageImporter.import_for(Team.new)
  end

  desc "Fetch all messages from a GMail account using EMAIL & PASSWORD and store them locally"
  namespace :import do
    task :account => :environment do
      AccountMessageImporter.import_for(ENV["EMAIL"], ENV["PASSWORD"])
    end
  end
end