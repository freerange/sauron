Feature: Show messages that we haven't yet responded to

Scenario: Mark messages without a response
  Given a message from outside the team without a response from the team
  When I visit the messages listing
  Then I should see that message highlighted as not having a response
