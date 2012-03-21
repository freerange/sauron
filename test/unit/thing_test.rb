# require 'test_helper'
# 
# class ThingTest < ActiveSupport::TestCase
# end

client = GmailImapClient.connect("email", "password")
repository = MessageRepository.new

MessageStorer.new()