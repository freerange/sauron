require Rails.root + 'test' + 'fakes' + 'fake_gmail'

After do
  FileUtils.rm_rf 'data/test'
  MailRepository::ActiveRecordMailIndex.destroy_all
  FakeGmail.server.reset!
end

Given /^the email account "([^"]*)" has mails in their Gmail inbox$/ do |account|
  [
    "Subject: Old message\nDate: 2012-05-23 12:34:45\nFrom: Dave",
    "Subject: New message\nDate: 2012-06-22 09:21:31\nFrom: Barry"
  ].each do |raw_mail|
    FakeGmail.server.accounts[account].add_mail(Mail.new(raw_mail))
  end
end

When /^the mails for account "([^"]*)" are imported$/ do |account|
  AccountMailImporter.import_for(account, 'password')
end

Then /^they should be visible on the messages page$/ do
  ENV['HTTP_PASSWORD'] = 'password'
  page.driver.browser.authorize('admin', 'password')

  visit "/"
  within ".message:first-child" do
    assert page.has_css? ".subject", text: "New message"
    assert page.has_css? ".date", text: "2012-06-22 09:21:31"
    assert page.has_css? ".sender", text: "Barry"
  end
  within ".message:last-child" do
    assert page.has_css? ".subject", text: "Old message"
    assert page.has_css? ".date", text: "2012-05-23 12:34:45"
    assert page.has_css? ".sender", text: "Dave"
  end
end


Given /^a team with credentials exists$/ do
  ENV["TEAM"] = "alice@example.com:bob@example.com"
  ENV["PASSWORDS"] = "alice-password:bob-password"
end

Given /^the team have mails in Gmail$/ do
  mail_to_alice = Mail.new("Subject: Hello Alice\nDate: 2012-05-23 12:34:45\nFrom: Bob")
  FakeGmail.server.accounts["alice@example.com"].add_mail(mail_to_alice)
  mail_to_bob = Mail.new("Subject: Hello Bob\nDate: 2012-05-27 12:35:56\nFrom: Alice")
  FakeGmail.server.accounts["bob@example.com"].add_mail(mail_to_bob)
end

When /^the periodic mail import occurs$/ do
  TeamMailImporter.import_for(Team.new)
end

Then /^all messages from all team members should be viewable$/ do
  ENV['HTTP_PASSWORD'] = 'password'
  page.driver.browser.authorize('admin', 'password')

  visit "/"
  within ".message:first-child" do
    assert page.has_css? ".subject", text: "Hello Bob"
    assert page.has_css? ".date", text: "2012-05-27 12:35:56"
    assert page.has_css? ".sender", text: "Alice"
  end
  within ".message:last-child" do
    assert page.has_css? ".subject", text: "Hello Alice"
    assert page.has_css? ".date", text: "2012-05-23 12:34:45"
    assert page.has_css? ".sender", text: "Bob"
  end
end