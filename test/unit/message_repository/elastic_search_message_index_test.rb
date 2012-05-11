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

    def mail_stub(attributes = {})
      stub("GoogleMail::Mailbox::Mail", {
        account: 'james@example.com',
        uid: rand(100000),
        message_id: SecureRandom.hex,
        subject: 'an-example-email',
        from: 'liam@example.com',
        date: Time.utc(2012, 7, 27, 20, 00, 00),
        delivered_to: 'james@example.com'
      }.merge(attributes))
    end

    test "#add adds the mail to the elastic search index" do
      index.add(mail)
      assert index.mail_exists?(mail.account, mail.uid)
    end

    test "#add returns an identifier that can be used to retrieve the message corresponding to a mail" do
      id = index.add(mail)
      message = index.find(id)
      assert_equal message.message_id, mail.message_id
    end

    test "#find returns message with the recipients as those every matching message was delivered to" do
      index.add(mail_stub(
        account: 'chris@example.com',
        message_id: 'unique-message-id',
        delivered_to: 'chris@example.com'
      ))

      id = index.add(mail_stub(
        account: 'tom@example.com',
        message_id: 'unique-message-id',
        delivered_to: 'tom@example.com'
      ))

      message = index.find(id)
      assert_equal ['chris@example.com', 'tom@example.com'].sort, message.recipients.sort
    end

    test "#find returns message with the subject, date and from fields of the original mail" do
      message = index.find(index.add(mail))
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

    test "#mail_exists? returns true if a matching mail has been added to an existing message" do
      first_mail = mail_stub(
        account: 'chris@example.com',
        message_id: 'unique-message-id',
      )

      second_mail = mail_stub(
        account: 'tom@example.com',
        message_id: 'unique-message-id'
      )

      first_id = index.add(first_mail)
      second_id = index.add(second_mail)

      assert_equal first_id, second_id
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

    # Non-core behaviour (bonus features!)

    test "#add uses identifiers that respect our existing urls" do
      id = index.add(mail)
      assert_equal id, Digest::SHA1.hexdigest(mail.message_id)
    end
  end
end