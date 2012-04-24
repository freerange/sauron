require "test_helper"
require "team_message_importer"

class TeamMessageImporterTest < ActiveSupport::TestCase
  test "imports messages for all members in a team" do
    team = stub("team")
    team.stubs(:each_member).multiple_yields(["alice@example.com", "alice-password"],
                                             ["bob@example.com", "bob-password"],
                                             ["clive@example.com", "clive-password"])
    AccountMessageImporter.expects(:import_for).with("alice@example.com", "alice-password")
    AccountMessageImporter.expects(:import_for).with("bob@example.com", "bob-password")
    AccountMessageImporter.expects(:import_for).with("clive@example.com", "clive-password")
    TeamMessageImporter.import_for(team)
  end
end