Feature: View messages in a conversation

Scenario: Show a list of conversations
  Given one message written in reply to another
  When I view the conversations
  Then I should see a single conversation for both messages

# Scenario: Show a conversation
#   Given one message written in reply to another
#   When I view the message
#   Then I should see both messages presented as a conversation