Feature: Don't show multiple copies of the same message as received by multiple people

Scenario: Hide duplicate messages
  Given the same message was received by multiple people in the team
  When the messages index is viewed
  Then the message should only appear once
  And all recipients of the message should be shown