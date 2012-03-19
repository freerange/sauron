require Rails.root + 'test' + 'mocks' + 'mock_gmail'

Given /^some messages exist on the server$/ do
  GmailAccount.email = 'test@example.com'
  GmailAccount.password = 'anything'
  [Mail.new("Subject: Message one"), Mail.new("Subject: Message two")].each do |message|
    MockGmail.server.accounts['test@example.com'].add_message('INBOX', message)
  end
end

Then /^they should be visible on the messages page$/ do
  visit "/"
  assert page.has_content?("Message one")
  assert page.has_content?("Message two")
end