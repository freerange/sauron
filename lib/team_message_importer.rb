class TeamMessageImporter
  class << self
    def import_for(team)
      team.each_member do |email, password|
        AccountMessageImporter.import_for(email, password)
      end
    end
  end
end