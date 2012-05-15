Feature: Exclude messages we believe to be automated from the main index

Scenario: Excluding automated messages
  Given messages sent from the following addresses:
  | description                    | address                                                       |
  | All notifications from pivotal | notifications@pivotaltracker.com                              |
  | A twitter mention              | mention-nqzva=unfuoyhr.pbz-26827@postmaster.twitter.com       |
  | A twitter follow               | twitter-follow-twitter=gofreerange.com@postmaster.twitter.com |
  | One twitter dm format          | twitter-dm-floehopper=googlemail.com@postmaster.twitter.com   |
  | Another twitter dm format      | dm-gjvggre=tbserrenatr.pbz-c222f@postmaster.twitter.com       |
  | Google calendar reminders      | calendar-notification@google.com                              |
  When I view the main list of messages
  Then I should not see any messages