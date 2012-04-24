require "test_helper"

class TeamTest < ActiveSupport::TestCase
  test "it yields each member of the team" do
    team = Team.new("alice@example.com" => "alice-password", "bob@example.com" => "bob-password")
    members = []
    team.each_member do |email, password|
      members << [email, password]
    end

    assert_equal [["alice@example.com", "alice-password"], ["bob@example.com", "bob-password"]], members
  end
end