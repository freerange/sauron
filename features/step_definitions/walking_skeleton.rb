require Rails.root + 'test' + 'fakes' + 'fake_gmail'

After do
  FileUtils.rm_rf 'data/test'
end

Given /^the email account "([^"]*)" has messages in their Gmail inbox$/ do |account|
  [
    "Subject: Old message\nDate: 2012-05-23 12:34:45\nFrom: Dave",
    "Subject: New message\nDate: 2012-06-22 09:21:31\nFrom: Barry"
  ].each do |raw_message|
    FakeGmail.server.accounts[account].add_message(Mail.new(raw_message))
  end
end

When /^the messages for account "([^"]*)" are imported$/ do |account|
  AccountMessageImporter.import_for(account, 'password')
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