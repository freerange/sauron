require "test_helper"

class TeamTest < ActiveSupport::TestCase
  test "it yields each member of the team" do
    ENV["TEAM"] = "alice@example.com:bob@example.com"
    ENV["PASSWORDS"] = "alice-password:bob-password"

    team = Team.new
    members = []
    team.each_member do |email, password|
      members << [email, password]
    end

    assert_equal [["alice@example.com", "alice-password"], ["bob@example.com", "bob-password"]], members
  end
end