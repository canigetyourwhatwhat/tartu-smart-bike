Feature: Ride and Report
  As a user
  Such that I have access to system's features
  I want to ride a bike

  Scenario: Ride a bike and report
    When I log in
    And I click Login
    And I click on "Unlock the bike"
    And I add bike id as "19147"
    And I submit
    Then I get a message as "Unlocked the bike! Enjoy your ride"
    And I click on "Lock the bike"
    And I select destination as "Delta"
    And I submit
    Then I get a message as "Ride information"
    And I go to Report an issue page
    And I add title as "some title", description as "some description", and id as "19147"
    And I submit
    Then I get a message as "Thank you for reporting an issue!"

  Scenario: Ride a bike and look at the history
    When I log in
    And I click Login
    And I click on "Unlock the bike"
    And I add bike id as "19147"
    And I submit
    Then I get a message as "Unlocked the bike! Enjoy your ride"
    And I click on "Lock the bike"
    And I select destination as "Delta"
    And I submit
    Then I get a message as "Ride information"
    And I click on "Home"
    And I click on "Ride history"
    Then I get a message as "Ride history"
    Then I get a message as "Delta"

  Scenario: Book a bike
    When I log in
    And I click Login
    And I click on "Map"
    And I start typing "Ilmatsalu"
    And I book a bike
    Then I get a successful booking message
    And I click on Cool
    And I click on "Home"
    And I click on "Ride history"
    Then I get a message as "Ride history"
    Then I get a message as "Ilmatsalu"
