Feature: Walking Skeleton

Scenario: Display messages which have been imported from the server
  Given the email account "bob@example.com" has messages in their Gmail inbox
  When the messages for account "bob@example.com" are imported
  Then they should be visible on the messages page

Scenario: Import messages from multiple accounts
  Given a team with credentials exists
  And the team have messages in Gmail
  When the periodic message import occurs
  Then all messages from all team members should be viewable