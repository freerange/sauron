# encoding: UTF-8
require 'test_helper'

class ParsedMailTest < ActiveSupport::TestCase
  test "returns the date" do
    raw_message = ::Mail.new(date: "2012-01-01 09:00:00").to_s
    assert_equal Time.parse("2012-01-01 09:00:00"), ParsedMail.new(raw_message).date
  end

  test "returns the message_id" do
    raw_message = Mail.new(message_id: "message-123").to_s
    assert_equal "message-123", ParsedMail.new(raw_message).message_id
  end

  test "returns the message id in the presence of messed up headers" do
    raw_message = %{Date: Sat, 21 Apr 2012 22:20:07 +0000
From: Pivotal Tracker <tracker-noreply@pivotaltracker.com>
To: jase@example.com,
james.adam@example.com,
chris.roos@example.com,
Peter.herlihy@example.com,
tom.ward@example.com,
james.mead@example.com,

jamie.arnold@example.com,
neil.williams@example.com,
frances@example.com,
ben.terrett@example.com
Message-Id: <4f9332975cb42_1df7ab6da78652@prod-app1.c44903.blueboxgrid.com.tmail>
Subject: Joe Bloggs has requested to be a member of an excitin project on Pivotal Tracker}
    assert_equal "<4f9332975cb42_1df7ab6da78652@prod-app1.c44903.blueboxgrid.com.tmail>", ParsedMail.new(raw_message).message_id
  end

  test "returns the sender defined by the From: header" do
    raw_message = Mail.new(from: "bob@example.com").to_s
    assert_equal "bob@example.com", ParsedMail.new(raw_message).from
  end

  test "returns nil when the message doesn't include a From: header" do
    raw_message = Mail.new(from: nil).to_s
    assert_nil ParsedMail.new(raw_message).from
  end

  test "returns the subject" do
    raw_message = Mail.new(subject: "email-subject").to_s
    assert_equal "email-subject", ParsedMail.new(raw_message).subject
  end

  test "handles pound signs encoded in Windows-1252 in the subject" do
    subject_with_invalid_encoding = "It costs \xA320. Bargain!".force_encoding("ASCII-8BIT")
    raw_message = "Subject: #{subject_with_invalid_encoding}"
    assert_equal "It costs £20. Bargain!", ParsedMail.new(raw_message).subject
  end

  test "handles ellipsis characters encoded in Windows-1252 in the subject" do
    subject_with_invalid_encoding = "Before \x85 After".force_encoding("ASCII-8BIT")
    raw_message = "Subject: #{subject_with_invalid_encoding}"
    assert_equal "Before … After", ParsedMail.new(raw_message).subject
  end

  test "handles en dashes encoded in Windows-1252 in the subject" do
    subject_with_invalid_encoding = "This \x96 that".force_encoding("ASCII-8BIT")
    raw_message = "Subject: #{subject_with_invalid_encoding}"
    assert_equal "This – that", ParsedMail.new(raw_message).subject
  end

  test "it doesn't do any conversion for strings that are already UTF-8" do
    utf_8_subject = "Unicode = \u00A3".encode("UTF-8")
    raw_message = "Subject: #{utf_8_subject}"
    assert_equal "Unicode = £", ParsedMail.new(raw_message).subject
  end

  test "returns nil when the message has an empty Subject header" do
    raw_message = Mail.new(subject: nil).to_s
    assert_nil ParsedMail.new(raw_message).subject
  end

  test "returns the typical single Delivered-To header as an Array of a single String" do
    raw_mail = "Delivered-To: alice@example.com\n\nmessage-body"
    assert_equal ["alice@example.com"], ParsedMail.new(raw_mail).delivered_to
  end

  test "returns weird multiple Delivered-To headers as an Array of Strings" do
    raw_mail = "Delivered-To: recipient-1\nDelivered-To: recipient-A\n\nmessage-body"
    assert_equal ["recipient-1", "recipient-A"], ParsedMail.new(raw_mail).delivered_to
  end

  test "body should be in UTF-8 even if raw message is in non UTF-8 encoding" do
    raw_mail = Mail.new(
      charset: 'ISO-8859-1',
      body: 'Telefónica'.encode('ISO-8859-1', 'UTF-8')
    ).encoded

    assert_equal 'Telefónica', ParsedMail.new(raw_mail).body
  end

  test "body should not fail decoding if charset unknown" do
    raw_mail = Mail.new(
      charset: 'unknown',
      body: 'Anything'
    ).encoded

    assert_nothing_raised { ParsedMail.new(raw_mail).body }
  end

  test "body should be in UTF-8 even if raw message contains text part which is in non UTF-8 encoding" do
    raw_mail = Mail.new do
      text_part do
        content_type 'text/plain; charset=ISO-8859-1'
        body 'Telefónica'.encode('ISO-8859-1', 'UTF-8')
      end
    end.encoded

    assert_equal 'Telefónica', ParsedMail.new(raw_mail).body
  end

  test "prefers the plain text body part" do
    raw_mail = Mail.new do
      text_part { body 'plain-text-message-body' }
      html_part do
        content_type 'text/html; charset=UTF-8'
        body '<h1>This is HTML</h1>'
      end
    end.encoded

    assert_equal 'plain-text-message-body', ParsedMail.new(raw_mail).body
  end

  test "shows all text parts when they are separated by an attachment" do
    raw_mail = Mail.new do
      text_part { body 'before-attachment' }
      add_file(__FILE__)
      text_part { body 'after-attachment' }
    end.encoded

    assert_match /before-attachment/, ParsedMail.new(raw_mail).body
    assert_match /after-attachment/, ParsedMail.new(raw_mail).body
  end

  test "shows text parts that are nested within multipart/alternative parts" do
    raw_mail = Mail.new do
      part do |p|
        p.text_part { body 'within-part' }
      end
    end.encoded

    assert_match /within-part/, ParsedMail.new(raw_mail).body
  end
end