require 'test_helper'

class MessageRepository
  class ElasticSearchMessageIndexTest < ActiveSupport::TestCase
    setup do
      index.reset!
    end

    def index
      @index ||= ElasticSearchMessageIndex.new
    end

    def mail
      @mail ||= mail_stub
    end

    test "#add adds the mail to the elastic search index" do
      index.add(mail)
      assert index.mail_exists?(mail.account, mail.uid)
    end

    test "#add returns a message corresponding to a mail" do
      message = index.add(mail)
      assert_equal message.message_id, mail.message_id
    end

    test "#find returns message with the recipients as those every matching message was delivered to" do
      index.add(mail_stub(
        account: 'chris@example.com',
        message_id: 'unique-message-id',
        delivered_to: ['chris@example.com']
      ))

      result = index.add(mail_stub(
        account: 'tom@example.com',
        message_id: 'unique-message-id',
        delivered_to: ['tom@example.com']
      ))

      message = index.find(result.id)
      assert_same_elements ['chris@example.com', 'tom@example.com'], message.recipients
    end

    test "#find returns message with the subject, date and from fields of the original mail" do
      result = index.add(mail)
      message = index.find(result.id)
      assert_equal message.subject, mail.subject
      assert_equal message.date, mail.date
      assert_equal message.from, mail.from
    end

    test "#find returns nil if a message with the given ID does not exist" do
      assert_nil index.find('made-up-id')
    end

    test "#mail_exists? returns true if a matching mail has been added" do
      index.add(mail)
      assert index.mail_exists?(mail.account, mail.uid)
    end

    test "#find returns messages with message_ids that are always Strings" do
      message_id = Mail.new("Message-Id: message-id").message_id
      mail = mail_stub(message_id: message_id)
      result = index.add(mail)
      message = index.find(result.id)
      assert_instance_of String, message.message_id
    end

    test "#mail_exists? returns true if a matching mail has been added to an existing message" do
      first_mail = mail_stub(
        account: 'chris@example.com',
        message_id: 'unique-message-id',
      )

      second_mail = mail_stub(
        account: 'tom@example.com',
        message_id: 'unique-message-id'
      )

      first_message = index.add(first_mail)
      second_message = index.add(second_mail)

      assert_equal first_message.id, second_message.id
      assert index.mail_exists?(first_mail.account, first_mail.uid)
      assert index.mail_exists?(second_mail.account, second_mail.uid)
    end

    test "#mail_exists? returns false if a matching mail has not been added" do
      refute index.mail_exists?(mail.account, mail.uid)
    end

    test "#mail_exists? requires an exact match on the account" do
      index.add(mail)
      refute index.mail_exists?('james', mail.uid)
    end

    test "#mail_exists? requires an exact match on the uid" do
      index.add(mail)
      refute index.mail_exists?(mail.account, 123)
    end

    test "#highest_uid returns the highest added uid for the given account" do
      10.times {|i| index.add(mail_stub(uid: i)) }
      assert_equal 9, index.highest_uid(mail.account)
    end

    test "#most_recent returns the 500 most recent mails" do
      mails = 501.times.collect {|i| mail_stub(date: i.minutes.ago)}
      mails.each {|mail| index.add(mail) }
      recent = index.most_recent
      assert_equal 500, recent.size
      assert_equal recent.first.message_id, mails[0].message_id
      assert_equal recent.to_a.last.message_id, mails[499].message_id
    end

    test "#most_recent excludes results matching passed in from addresses" do
      index.add(mail_stub(from: 'a@example.com'))
      index.add(mail_stub(from: 'b@example.com'))
      index.add(mail_stub(from: 'c@example.com'))
      recent = index.most_recent(excluding: ['a@example.com', 'c@example.com'])
      assert_equal 1, recent.size
      assert_equal recent.first.from, 'b@example.com'
    end

    test "#most_recent excludes results matching wilcard addresses" do
      index.add(mail_stub(from: 'albert@example.com'))
      index.add(mail_stub(from: 'barry@example.com'))
      index.add(mail_stub(from: 'andrew@example.com'))
      recent = index.most_recent(excluding: ['a*@example.com'])
      assert_equal 1, recent.size
      assert_equal recent.first.from, 'barry@example.com'
    end

    test "#search returns messages containing the search term in their subject" do
      index.add(mail_stub(subject: 'llama zebra tiger'))
      index.add(mail_stub(subject: 'zebra rabbit koala'))
      index.add(mail_stub(subject: 'marmoset adder penguin'))
      results = index.search('zebra')
      assert_equal 2, results.length
      assert results.detect {|r| r.subject == 'llama zebra tiger'}
      assert results.detect {|r| r.subject == 'zebra rabbit koala'}
    end

    test "#search returns messages containing the search term in their body" do
      index.add(mail_stub(body: 'llama zebra tiger'))
      index.add(mail_stub(body: 'zebra rabbit koala'))
      index.add(mail_stub(body: 'marmoset adder penguin'))
      results = index.search('zebra')
      assert_equal 2, results.length
      assert results.detect {|r| r.body == 'llama zebra tiger'}
      assert results.detect {|r| r.body == 'zebra rabbit koala'}
    end

    test "#search returns matching messages in reverse chronological order" do
      index.add(mail_stub(subject: 'subject-3', date: 3.days.ago))
      index.add(mail_stub(subject: 'subject-2', date: 2.days.ago))
      index.add(mail_stub(subject: 'subject-1', date: 1.day.ago))
      results = index.search('subject')
      assert_equal %w(subject-1 subject-2 subject-3), results.map(&:subject)
    end

    test "#search returns messages containing the search term as their from address" do
      index.add(mail_stub(from: 'tom@example.com'))
      index.add(mail_stub(from: 'chris@example.com'))
      results = index.search('tom@example.com')
      assert_equal 1, results.length
      assert_equal 'tom@example.com', results.first.from
    end

    test "#search returns messages containing the search term in their to addresses" do
      index.add(mail_stub(to: ['tom@example.com', 'bob@example.com']))
      index.add(mail_stub(to: ['chris@example.com']))
      results = index.search('tom@example.com')
      assert_equal 1, results.length
      assert_equal ['tom@example.com', 'bob@example.com'], results.first.to
    end

    test "#search returns messages containing the search term in their cc addresses" do
      index.add(mail_stub(cc: ['tom@example.com', 'bob@example.com']))
      index.add(mail_stub(cc: ['chris@example.com']))
      results = index.search('tom@example.com')
      assert_equal 1, results.length
      assert_equal ['tom@example.com', 'bob@example.com'], results.first.cc
    end

    test "#search ignores fields other than the subject, body, to, cc, bcc and from" do
      index.add(mail_stub(
        account: 'message',
        uid: 'message',
        message_id: 'message'
      ))
      results = index.search('message')
      assert_equal 0, results.length
    end

    # Non-core behaviour (bonus features!)

    test "#add uses identifiers that respect our existing urls" do
      message = index.add(mail)
      assert_equal message.id, Digest::SHA1.hexdigest(mail.message_id)
    end
  end
end