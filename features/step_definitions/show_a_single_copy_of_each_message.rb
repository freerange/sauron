Given /^the same message was received by multiple people in the team$/ do
  generic_mail_bit = "Subject: Exciting message\nDate: 2012-05-23 12:34:45\nFrom: Dave\nMessage-ID: <abc123-def456@123.example.com>"
  alice_mail = "Delivered-To: alice@example.com\n" + generic_mail_bit
  bob_mail = "Delivered-To: bob@example.com\n" + generic_mail_bit
  FakeGmail.server.accounts["alice@example.com"].add_mail(Mail.new(alice_mail))
  FakeGmail.server.accounts["bob@example.com"].add_mail(Mail.new(bob_mail))

  AccountMailImporter.import_for("alice@example.com", 'password')
  AccountMailImporter.import_for("bob@example.com", 'password')
end

When /^the messages index is viewed$/ do
  login
  visit "/"
end

Then /^the message should only appear once$/ do
  assert page.has_css? ".message .subject", text: "Exciting message", count: 1
end

Then /^all recipients of the message should be shown$/ do
  click_link "Exciting message"
  assert page.has_css? ".message .recipients .recipient", count: 2
  assert page.has_css? ".message .recipients .recipient", text: 'alice@example.com'
  assert page.has_css? ".message .recipients .recipient", text: 'bob@example.com'
end