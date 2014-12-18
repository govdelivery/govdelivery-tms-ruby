Feature: XACT reserved keyword creation

    @reservedkeyword
	Scenario Outline: XACT reserved keyword creation
		Given I attempt to create a reserved keyword <keyword>
		Examples:
		| keyword |
		| stop |
		| unsubscribe |
		| cancel |
		| stopall |
		| end |
		| quit |
		| start |
		| yes |
		| info |
		