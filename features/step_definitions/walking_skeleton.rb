require Rails.root + 'test' + 'fakes' + 'fake_gmail'

After do
  FileUtils.rm_rf 'data/test'
end

Given /^the email account "([^"]*)" has messages in their Gmail inbox$/ do |account|
  [
    Mail.new("Subject: Message one\nDate: 2012-05-23 12:34:45\nFrom: Dave"),
    Mail.new("Subject: Message two\nDate: 2012-06-22 09:21:31\nFrom: Barry")
  ].each do |message|
    FakeGmail.server.accounts[account].add_message(message)
  end
end

When /^the messages for account "([^"]*)" are imported$/ do |account|
  MessageImporter.new(GmailImapClient.connect(account, 'password')).import_into(MessageRepository.instance)
end

Then /^they should be visible on the messages page$/ do
  ENV['HTTP_PASSWORD'] = 'password'
  page.driver.browser.authorize('admin', 'password')

  visit "/"
  within ".message" do
    assert page.has_css? ".subject", "Message one"
    assert page.has_css? ".date", "2012-05-23 12:34:45"
    assert page.has_css? ".sender", "Dave"
  end
  within ".message" do
    assert page.has_css? ".subject", "Message two"
    assert page.has_css? ".date", "2012-06-22 09:21:31"
    assert page.has_css? ".sender", "Barry"
  end
end