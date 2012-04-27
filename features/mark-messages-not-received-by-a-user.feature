Feature: Mark messages not received by a user

Scenario: A message is received by one user but not by another
  Given one user received a message but another did not 
  When the messages index is viewed by the user who did not receive a message
  Then the message should be marked as not received
