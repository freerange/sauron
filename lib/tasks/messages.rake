namespace :messages do
  desc "Fetch all messages for all credentials in TEAM/PASSWORDS"
  task :import => :environment do
    env = Env.new
    TeamMessageImporter.import_for(Team.new(Env.emails_vs_passwords))
  end

  desc "Fetch all messages from a GMail account using EMAIL & PASSWORD and store them locally"
  namespace :import do
    task :account => :environment do
      env = Env.new
      TeamMessageImporter.import_for(Team.new(env.email => env.password))
    end
  end
end