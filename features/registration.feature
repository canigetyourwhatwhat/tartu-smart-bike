Feature: User registration
  As a user
  Such that I don't have access to system's features
  I want to register a new account

  Scenario: Registering in the system (with confirmation), login the system (with success) and logout
    When I go to Registration page
    And I input my name as "Adil Shirinov", email "adil123@gmail.com", birthdate "12/02/1999", password "adil123"
    And I input payment_method as "Credit Card", card_number "123456789", subscription_type "1-year membership"
    And I click Register
    Then I get a message as "Account created successfully"
    And I go to Login page
    And I input my email as "adil123@gmail.com" and password "adil123"
    And I click Login
    Then I get a success message as "Welcome, Adil Shirinov!"
    And I click Logout
    Then I logged out

  Scenario: Registering in the system (with rejection)
    When I go to Registration page
    And I input my name as "Adil Shirinov", email "adil@gmail.com", birthdate "12/02/1999", password "123"
    And I input payment_method as "Credit Card", card_number "123456789", subscription_type "1-year membership"
    And I click Register
    Then I get an error message

  Scenario: Login in the system (with fail)
    When I go to Login page
    And I input my email as "adil123@gmail.com" and password "adil123"
    And I click Login
    Then I get a fail message
