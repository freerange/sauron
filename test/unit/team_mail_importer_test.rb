require "test_helper"
require "team_mail_importer"

class TeamMailImporterTest < ActiveSupport::TestCase
  test "imports messages for all members in a team" do
    team = Team.new
    team.stubs(:each_member).multiple_yields(["alice@example.com", "alice-password"],
                                             ["bob@example.com", "bob-password"],
                                             ["clive@example.com", "clive-password"])
    AccountMailImporter.expects(:import_for).with("alice@example.com", "alice-password")
    AccountMailImporter.expects(:import_for).with("bob@example.com", "bob-password")
    AccountMailImporter.expects(:import_for).with("clive@example.com", "clive-password")
    TeamMailImporter.import_for(team)
  end
end