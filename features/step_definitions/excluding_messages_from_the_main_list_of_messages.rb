Given /^messages sent from the following addresses:$/ do |table|
  table.hashes.each do |attributes|
    mail = Mail.new(subject: 'Anything', from: attributes['address'])
    FakeGmail.server.accounts["alice@example.com"].add_mail(mail)
  end
  AccountMailImporter.import_for("alice@example.com", "password")
end

When /^I view the main list of messages$/ do
  login
  visit "/"
end

Then /^I should not see any messages$/ do
  refute page.has_css? '.message'
end