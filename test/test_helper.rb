ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'fakes/fake_gmail'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  def assert_same_elements(expected, actual, message=nil)
    assert_equal expected.sort, actual.sort, message
  end

  def mail_stub(name, attributes = {})
    stub(name, {
      account: 'james@example.com',
      uid: rand(100000),
      message_id: SecureRandom.hex,
      subject: 'an-example-email',
      from: 'liam@example.com',
      to: ['baz@example.com'],
      cc: ['mike@example.com'],
      date: Time.utc(2012, 7, 27, 20, 00, 00),
      delivered_to: ['james@example.com'],
      body: 'Any old body'
    }.merge(attributes)).responds_like(GoogleMail::Mailbox::Mail.new(nil, nil, nil))
  end

  def message_stub(name, attributes = {})
    stub(name, {
      recipients: [],
      to: [],
      sent_or_received_by?: false,
      date: Time.now,
      subject: 'subject',
      from: 'sender',
      body: 'body',
      displayable_raw_mail: 'displayable-raw-mail',
      message_id: SecureRandom.hex,
      in_reply_to: nil
    }.merge(attributes)).responds_like(MessageRepository::Message.new(nil, nil))
  end

  def reply_to(message, name, attributes={})
    message_stub(name, {in_reply_to: message.message_id, subject: message.subject}.merge(attributes))
  end

  def conversation_stub(name, attributes = {})
    stub(name, {
      latest_message_date: Time.now,
      subject: 'subject',
    }.merge(attributes)).responds_like(ConversationRepository::Conversation.new)
  end
end

Mocha::Configuration.prevent(:stubbing_non_existent_method)

class ActionController::TestCase
  def logged_in
    ENV["TEAM"] = "alice@example.com"
    ENV["HTTP_PASSWORD"] = "password"
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("alice@example.com:password")
  end
end