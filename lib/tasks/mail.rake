namespace :mail do
  desc "Fetch all mails for all credentials in TEAM/PASSWORDS"
  task :import => :environment do
    Rails.logger.info("Starting import at #{Time.now}")
    begin
      TeamMailImporter.import_for(Team.new)
    rescue Object => e
      Rails.logger.info("Import failed at #{Time.now}:")
      Rails.logger.info(e)
      Rails.logger.info(e.backtrace.join("\n"))
      raise e
    end
    Rails.logger.info("Done import at #{Time.now}")
  end
end