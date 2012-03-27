require 'test_helper'

describe GoogleMail::Mailbox::AuthenticatedConnection do
  describe '.new(email, password)' do
    subject { GoogleMail::Mailbox::AuthenticatedConnection }
    stub(:imap, login: nil)

    it 'starts a secure connection with the GoogleMail imap server' do
      Net::IMAP.expects(:new).with('imap.gmail.com', 993, true).returns(imap)
      subject.new('email', 'password')
    end

    it 'authenticates the connection with the given email and password' do
      Net::Imap.stubs(:new).returns(imap)
      imap.expects(:login).with('mike@example.com', 'password123')
      subject.new('mike@example.com', 'password123')
    end
  end

  describe '(in general)' do
    stub(:imap, login: nil)
    subject {
      # It feels that because I have to do this (and I know it could be done in a before block) that
      # maybe the connection should be passed in somehow?  The previous tests didn't hint that as much.
      # I think I would prefer to add an `AuthenticatedConnection.connect` method that builds the imap
      # connection and passes it into the model, to be used in place of `.new`
      Net::Imap.stubs(:new).returns(imap)
      GoogleMail::Mailbox::AuthenticatedConnection.new 'barry@example.com', 'password911'
    }

    it 'remembers the email address it was instantiated with' do
      expect(subject.email).to eql('barry@example.com')
    end

    # Are tests like these needed?  I think so.
    it 'delegates calls to the imap connection' do
      imap.stubs(:uid_fetch).with(123, 'BODY.PEEK[]').returns(:result_from_imap)
      expect(subject.uid_fetch(123, 'BODY.PEEK[]').to eql(:result_from_imap)
    end
  end
end

module GoogleMail
  class Mailbox::AuthenticatedConnectionTest < ActiveSupport::TestCase
    stub(:imap, login: nil)

    test "should connect to the gmail imap server" do
      Net::IMAP.expects(:new).with('imap.gmail.com', 993, true).returns(imap)
      Mailbox::AuthenticatedConnection.new('email', 'password')
    end

    test "should login using the supplied email and password" do
      email, password = "email", "password"
      imap.expects(:login).with(email, password)
      Net::IMAP.stubs(:new).returns(imap)
      Mailbox::AuthenticatedConnection.new(email, password)
    end

    test "gives access to the email address the account represents" do
      email, password = "email", "password"
      Net::IMAP.stubs(:new).returns(imap)
      assert_equal 'email', Mailbox::AuthenticatedConnection.new(email, password).email
    end
  end
end