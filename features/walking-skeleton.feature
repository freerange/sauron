Feature: Walking Skeleton

Scenario: Display messages which have been imported from the server
  Given the email account "bob@example.com" has mails in their Gmail inbox
  When the mails for account "bob@example.com" are imported
  Then they should be visible on the messages page

Scenario: Import messages from multiple accounts
  Given a team with credentials exists
  And the team have mails in Gmail
  When the periodic mail import occurs
  Then all messages from all team members should be viewable