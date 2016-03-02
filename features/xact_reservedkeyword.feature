@reservedkeyword
Feature: XACT reserved keyword creation

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
