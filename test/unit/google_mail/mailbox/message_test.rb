require 'test_helper'

class GoogleMail::Mailbox
  class MessageTest < ActiveSupport::TestCase
    test "builds a MailWrapper with the raw message content" do
      wrapper = stub('wrapper')
      MailWrapper.stubs(:new).with(:raw_message_content).returns(wrapper)
      message = Message.new('tom@example.com', 1, :raw_message_content)
      assert_equal wrapper, message.wrapper
    end

    [:from, :subject, :message_id, :date].each do |method|
      test "delegates #{method} to the MailWrapper" do
        message = Message.new('tom@example.com', 1, :raw_message_content)
        result = stub('wrapper-response')
        message.wrapper.stubs(method).returns(result)
        assert_equal result, message.__send__(method)
      end
    end
  end
end
