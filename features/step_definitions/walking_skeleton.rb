Given /^some messages exist on the server$/ do
  GmailAccount.stubs(:messages).returns([Mail.new("Subject: Message one"), Mail.new("Subject: Message two")])
end

Then /^they should be visible on the messages page$/ do
  visit "/"
  assert page.has_content?("Message one")
  assert page.has_content?("Message two")
end