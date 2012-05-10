Given /^one user received a message but another did not$/ do
  message = "To: alice@example.com\nSubject: Secret message\nDate: 2012-05-23 12:34:45\nFrom: Dave\nMessage-ID: <abc123-def456@123.example.com>"
  FakeGmail.server.accounts["alice@example.com"].add_mail(Mail.new(message))
  AccountMailImporter.import_for("alice@example.com", "password")
end

When /^the messages index is viewed by the user who did not receive a message$/ do
  ENV['TEAM'] = 'alice@example.com:bob@example.com'
  ENV['HTTP_PASSWORD'] = 'password'
  page.driver.browser.authorize('bob@example.com', 'password')
  visit '/'
end

Then /^the message should be marked as not received$/ do
  assert page.has_css? '.message.neither-sent-nor-received', text: /Secret message/
end
