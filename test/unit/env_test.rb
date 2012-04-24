require "test_helper"

class EnvTest < ActiveSupport::TestCase
  test "extracts single email address from the EMAIL environment variable" do
    env = Env.new("EMAIL" => "alice@example.com")
    assert_equal "alice@example.com", env.email
  end

  test "extracts single password from the PASSWORD environment variable" do
    env = Env.new("PASSWORD" => "alice-password")
    assert_equal "alice-password", env.password
  end

  test "extracts array of email addresses from the TEAM environment variable" do
    env = Env.new("TEAM" => "alice@example.com:bob@example.com")
    assert_equal ["alice@example.com", "bob@example.com"], env.emails
  end

  test "extracts array of passwords from the PASSWORDS environment variable" do
    env = Env.new("PASSWORDS" => "alice-password:bob-password")
    assert_equal ["alice-password", "bob-password"], env.passwords
  end

  test "extracts hash of emails versus passwords from the TEAM and PASSWORDS environment variables" do
    env = Env.new("TEAM" => "alice@example.com:bob@example.com", "PASSWORDS" => "alice-password:bob-password")
    assert_equal({"alice@example.com" => "alice-password", "bob@example.com" => "bob-password"}, env.emails_vs_passwords)
  end
end