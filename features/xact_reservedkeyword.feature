Feature: XACT reserved keyword creation

    @reservedkeyword
	Scenario Outline: XACT reserved keyword creation
		Given I attempt to create a reserved keyword <keyword>
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
		