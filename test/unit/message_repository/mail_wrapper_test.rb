require "test_helper"

class MessageRepository
  class MailWrapperTest < ActiveSupport::TestCase
    test "returns the sender defined by the From: header" do
      raw_message = Mail.new(from: "bob@example.com").to_s
      assert_equal "bob@example.com", MailWrapper.new(raw_message).from
    end

    test "returns nil when the message doesn't include a From: header" do
      raw_message = Mail.new(from: nil).to_s
      assert_nil MailWrapper.new(raw_message).from
    end

    test "returns the subject" do
      raw_message = Mail.new(subject: "email-subject").to_s
      assert_equal "email-subject", MailWrapper.new(raw_message).subject
    end

    test "returns the date" do
      raw_message = Mail.new(date: "2012-01-01 09:00:00").to_s
      assert_equal Time.parse("2012-01-01 09:00:00"), MailWrapper.new(raw_message).date
    end
  end
end