Given /^a message from outside the team without a response from the team$/ do
  message = "To: alice@example.com\nSubject: Question for you\nDate: 2012-05-23 12:34:45\nFrom: dave@othercompany.example.com\nMessage-ID: <abc123-def456@123.example.com>"
  FakeGmail.server.accounts["alice@example.com"].add_mail(Mail.new(message))
  AccountMailImporter.import_for("alice@example.com", "password")
end

When /^I visit the messages listing$/ do
  ENV['TEAM'] = 'alice@example.com:bob@example.com'
  ENV['HTTP_PASSWORD'] = 'password'
  page.driver.browser.authorize('bob@example.com', 'password')
  visit '/'
end

Then /^I should see that message highlighted as not having a response$/ do
  assert page.has_css? ".message.needs_response .subject", text: "Question for you"
end