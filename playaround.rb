require 'net/imap'
require 'mail'

email = ENV['EMAIL']
password = ENV['PASSWORD']

@imap = Net::IMAP.new('imap.gmail.com', 993, ssl=true)
@imap.login(email, password)
@imap.select 'INBOX'
raw = @imap.uid_search('ALL').map {|uid| @imap.uid_fetch(uid, 'BODY.PEEK[]')[0].attr['BODY[]']}
messages = raw.map {|m| Mail.new m}

messages.each do |m|
  puts m.subject
end