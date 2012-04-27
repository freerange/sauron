namespace :messages do
  desc "Fetch all messages for all credentials in TEAM/PASSWORDS"
  task :import => :environment do
    TeamMessageImporter.import_for(Team.new)
  end
end