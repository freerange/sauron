Given /^one message written in reply to another$/ do
  original_mail = %{Delivered-To: alice@example.com\nSubject: How are you?\nDate: 2012-05-21 12:22:51\nFrom: "Alice" <alice@example.com>\nTo: "Bob" <bob@example.com>\nMessage-ID: <message-id-1@123.example.com>}
  FakeGmail.server.accounts["alice@example.com"].add_mail(Mail.new(original_mail))

  reply_mail = %{Delivered-To: alice@example.com\nSubject: Re: How are you?\nDate: 2012-05-23 12:34:56\nTo: "Alice" <alice@example.com>\nFrom: "Bob" <bob@example.com>\nIn-Reply-To: <message-id-1@123.example.com>\nMessage-ID: <message-id-2@456.example.com}
  FakeGmail.server.accounts["alice@example.com"].add_mail(Mail.new(reply_mail))

  AccountMailImporter.import_for("alice@example.com", 'password')
end

When /^I view the conversations$/ do
  login
  visit "/conversations"
end

Then /^I should see a single conversation for both messages$/ do
  save_and_open_page
  assert page.has_css?(".conversation", count: 1), "should only show one entry for the two messages"
  within ".conversation" do
    assert page.has_css?(".subject", text: "Re: How are you?"), "should show subject" # could remove Re:
    assert page.has_css?(".date[title='2012-05-23T12:34:56Z']"), "should show the most recent date"
    assert page.has_css?(".participants", text: "alice@example.com, bob@example.com"), "should show all the participants"
  end
end
