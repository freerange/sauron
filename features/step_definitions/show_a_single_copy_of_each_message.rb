Given /^the same message was received by multiple people in the team$/ do
  generic_message_bit = "Subject: Exciting message\nDate: 2012-05-23 12:34:45\nFrom: Dave\nMessage-ID: <abc123-def456@123.example.com>"
  alice_message = "To: alice@example.com\n" + generic_message_bit
  bob_message = "To: bob@example.com\n" + generic_message_bit
  FakeGmail.server.accounts["alice@example.com"].add_message(Mail.new(alice_message))
  FakeGmail.server.accounts["bob@example.com"].add_message(Mail.new(bob_message))

  AccountMessageImporter.import_for("alice@example.com", 'password')
  AccountMessageImporter.import_for("bob@example.com", 'password')
end

When /^the messages index is viewed$/ do
  ENV['HTTP_PASSWORD'] = 'password'
  page.driver.browser.authorize('admin', 'password')

  visit "/"
end

Then /^the message should only appear once$/ do
  assert page.has_css? ".message .subject", text: "Exciting message", count: 1
end