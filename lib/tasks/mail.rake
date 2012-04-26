namespace :mail do
  desc "Fetch all mails for all credentials in TEAM/PASSWORDS"
  task :import => :environment do
    TeamMessageImporter.import_for(Team.new)
  end
end