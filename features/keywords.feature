@full-regression @QC-2440
Feature: Interacting with TMS keywords

  @QC-2453
  Scenario: TMS configure a text response for an SMS keyword under 160 characters.
    When I create a new keyword with a text response
    Then I should be able to delete the keyword

  @QC-2496
  Scenario: TMS configure a text response for an SMS keyword over 160 characters.
    When I attempt to create a keyword with a response text over 160 characters
    Then I should receive the error "is too long (maximum is 160 characters)" in the "response_text" payload

  @QC-2492
  Scenario: TMS creating and deleting Forward commands for a Keyword.
    When I create a new forward keyword and command
    Then I should be able to delete the forward keyword

  @QC-2488
  Scenario: TMS creating and deleting Subscribe commands for a Keyword.
    When I create a new subscribe keyword and command
    Then I should be able to delete the subscribe keyword

  @QC-2488
  Scenario: TMS creating and deleting Unsubscribe commands for a Keyword.
    When I create a new unsubscribe keyword and command
    Then I should be able to delete the unsubscribe keyword

  @QC-2452 @keyword
  Scenario: TMS creating and deleting Subscribe commands for a Keyword when the account is invalid.
    When I create a keyword and command with an invalid account code
    Then I should receive the error "Dcm account code is not a valid code" in the "params" payload

  @reservedkeyword
  Scenario Outline: XACT reserved keyword creation
    When I attempt to create a reserved keyword <keyword>
    Then I should receive an reserved keyword message
    Examples:
      | keyword |
      | unsubscribe |
      | cancel |
      | stopall |
      | end |
      | quit |
      | yes |
      | info |
