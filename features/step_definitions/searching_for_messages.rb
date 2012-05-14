Given /^a message with the subject "([^"]*)"$/ do |subject|
  @mail = Mail.new(subject: subject)
  FakeGmail.server.accounts["alice@example.com"].add_mail(@mail)
  AccountMailImporter.import_for("alice@example.com", 'password')
end

When /^I search for the term "([^"]*)"$/ do |term|
  login
  visit "/"
  fill_in "Search", with: term
  click_button "Search"
end

Then /^the message should be included in the search results$/ do
  assert page.has_css? ".message .subject", text: @mail.subject, count: 1
end