namespace :mail do
  desc "Fetch all mails for all credentials in TEAM/PASSWORDS"
  task :import => :environment do
    Rails.logger.info("Starting import at #{Time.now}")
    begin
      IntermittentErrorHandler.new(Rails.logger) do
        IntermittentImapErrorFilter.new do
          TeamMailImporter.import_for(Team.new)
        end
      end
    rescue Object => e
      messages = [
        "Import failed at #{Time.now}:",
        e,
        e.class,
        e.instance_variables.inject({}) { |h, v| h[v] = e.instance_variable_get(v); h },
        e.respond_to?(:response) ? e.response : nil,
        e.backtrace.join("\n")
      ].compact
      messages.each { |m| Rails.logger.info(m) }
      messages.each { |m| puts m }
      raise e
    end
    Rails.logger.info("Done import at #{Time.now}")
  end
end
