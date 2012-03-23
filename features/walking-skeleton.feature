Feature: Walking Skeleton

Scenario: Display messages which have been imported from the server
  Given the email account "bob@example.com" has messages in their Gmail inbox
  When the messages for account "bob@example.com" are imported
  Then they should be visible on the messages page