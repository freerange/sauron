class TeamMailImporter
  class << self
    def import_for(team)
      team.each_member do |email, password|
        AccountMailImporter.import_for(email, password)
      end
    end
  end
end