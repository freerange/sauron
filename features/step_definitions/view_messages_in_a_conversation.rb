Given /^one message written in reply to another$/ do
  original_mail = %{Delivered-To: alice@example.com\nSubject: How are you?\nDate: 2012-05-21 12:22:51\nFrom: "Alice" <alice@example.com>\nTo: "Bob" <bob@example.com>\nMessage-ID: <message-id-1@123.example.com>\n\nHey Bob!}
  FakeGmail.server.accounts["alice@example.com"].add_mail(Mail.new(original_mail))

  reply_mail = %{Delivered-To: alice@example.com\nSubject: Re: How are you?\nDate: 2012-05-23 12:34:56\nTo: "Alice" <alice@example.com>\nFrom: "Bob" <bob@example.com>\nIn-Reply-To: <message-id-1@123.example.com>\nMessage-ID: <message-id-2@456.example.com\n\nHey Alice!}
  FakeGmail.server.accounts["alice@example.com"].add_mail(Mail.new(reply_mail))

  AccountMailImporter.import_for("alice@example.com", 'password')
end

When /^I view the conversations$/ do
  login
  visit "/conversations"
end

Then /^I should see a single conversation for both messages$/ do
  assert page.has_css?(".conversation", count: 1), "should only show one entry for the two messages"
  within ".conversation" do
    assert page.has_css?(".subject", text: "Re: How are you?"), "should show subject" # could remove Re:
    assert page.has_css?(".date[title='2012-05-23T12:34:56Z']"), "should show the most recent date"
    assert page.has_css?(".participants", text: "alice@example.com, bob@example.com"), "should show all the participants"
  end
end

When /^I view the conversation$/ do
  login
  visit "/conversations"
  click_link "Re: How are you?"
end

Then /^I should see both messages presented in the conversation$/ do
  within ".conversation" do
    assert page.has_css?(".subject", text: "Re: How are you?"), "show show the subject of the conversation"
    assert page.has_css?(".body", text: "Hey Bob!"), "should show the body of the first message"
    assert page.has_css?(".body", text: "Hey Alice!"), "should show the body of the second message"
  end
end