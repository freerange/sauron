namespace :messages do
  task :import => :environment do
    AccountMessageImporter.import_for(ENV["EMAIL"], ENV["PASSWORD"])
  end
end