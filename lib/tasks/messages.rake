namespace :messages do
  desc "Fetch all messages from a GMail account using EMAIL & PASSWORD and store them locally"
  task :import => :environment do
    AccountMessageImporter.import_for(ENV["EMAIL"], ENV["PASSWORD"])
  end
end