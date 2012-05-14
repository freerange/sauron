Feature: Searching for messages

Scenario: Finding messages based on their subject
  Given a message with the subject "A Brief History of Time"
  When I search for the term "History"
  Then the message should be included in the search results
