Feature: XACT Full Regression


#misc


    @QC-2453 @QC-2440
	Scenario: TMS configure a text response for an SMS keyword under 160 characters.
		Given I create a new keyword with a text response
        Then I should be able to create and delete the keyword

    @QC-2496 @QC-2440 
	Scenario: TMS configure a text response for an SMS keyword over 160 characters.
		Given I attempt to create a keyword with a response text over 160 characters

    @QC-2492 @QC-2440 
	Scenario: TMS creating and deleting Forward commands for a Keyword.
		Given I create a new forward keyword and command
        And I should be able to delete the forward keyword

    @QC-2488 @QC-2440 
	Scenario: TMS creating and deleting Subscribe, Unsubscribe commands for a Keyword. 
		Given I create a new subscribe keyword and command
        And I should be able to delete the subscribe keyword
        Given I create a new unsubscribe keyword and command
        And I should be able to delete the unsubscribe keyword

    @QC-2452 @QC-2440 
	Scenario: TMS creating and deleting Subscribe commands for a Keyword when the account is invalid.
		Given I create a keyword and command with an invalid account code
        Then I should receive an error


#admin template and link tracking params tests

	@XACT-533-2 @QC-2239
    Scenario: Check that params resolve correctly
    	Given I am a TMS admin
    	And I send an email from an account that has link tracking params configured
    	Then those params should resolve within the body of the email I send

	#@XACT-533-3
    #Scenario: TMS admin creation of link tracking params
    #	Given I am a TMS admin
    #	Then I should be able to enter link tracking params at the account level

	#@XACT-533-4 @XACT-545-2
    #Scenario: TMS admin verify that templates are registered on messages-email endpoint
    #	Given I am a TMS admin
    #	Then I should be able to create and list templates for email messages
    #	And I should be able to verify that all required fields are listed

	@XACT-533-5 @QC-2239
    Scenario: TMS admin verify that link tracking params are only available internally
    	Given I am a TMS user and not an admin
    	Then I should not be able to see the accounts endpoint

    #@XACT-545-1
    #Scenario: TMS admin verify that templates can be read, updated, listed, and deleted
    #	Given I am a TMS admin
    #	Then I should be able to create, update, list, and delete templates



#email    	


    @QC-2456 @QC-2239
	Scenario: TMS verify the ability to disable open and click tracking in my EMAIL sends
		Given I verify the ability to disable open and click tracking in my EMAIL sends

    @QC-2520 @QC-2239
	Scenario: TMS posting a new EMAIL with message and recipient MACROS
		Given I post a new EMAIL with message and recipient MACROS
       
    @QC-2292 @QC-2239 
	Scenario: TMS posting a new EMAIL message with an empty BODY produces a 422 error
		Given I post a new EMAIL message with an empty BODY produces an error
        
    @QC-2294 @QC-2239 
	Scenario: TMS posting a new EMAIL message with an empty SUBJECT produces a 422 error
		Given I post a new EMAIL message with an empty SUBJECT produces an error
        
    @QC-2295 @QC-2239 
	Scenario: TMS posting a new EMAIL message to multiple RECIPIENTS
		Given I post a new EMAIL message to multiple RECIPIENTS
        
    @QC-2296 @QC-2239
	Scenario: TMS posting a new EMAIL message with no RECIPIENTS produces a 422 created response
		Given I post a new EMAIL message with no RECIPIENTS produces an error
        
    @QC-2365 @QC-2239
	Scenario: TMS posting a new EMAIL message and retrieve the list recipient counts/states
		Given I post a new EMAIL message and retrieve the list recipient counts/states
        
    @QC-2387 @QC-2239
	Scenario: TMS posting a new EMAIL message with HTML within the message body
		Given I post a new EMAIL message with HTML within the message body
        
    @QC-2420 @QC-2239
	Scenario: TMS posting a new EMAIL message with inline CSS in the message
		Given I post a new EMAIL message with inline CSS in the message
        
    @QC-2472 @QC-2239 
	Scenario: TMS posting a new EMAIL message with 1 VALID and 1 INVALID RECIPIENT produces a 201 created response and a failed recipient
		Given I post a new EMAIL message with a VALID and INVALID RECIPIENT produces an email

    @QC-3227 @QC-2239 
	Scenario: TMS posting a new EMAIL message with an empty FROM_EMAIL produces a 422 response
		Given I post a new EMAIL message with an empty FROM_EMAIL produces an error

    @QC-3233 @QC-2239 
	Scenario: TMS posting a new EMAIL message with an empty REPLY_TO produces a 201 created response, defaults to the account level FROM_ADDRESS.
		Given I post a new EMAIL message with an empty REPLY_TO produces an email

    @QC-3234 @QC-2239 
	Scenario: TMS posting a new EMAIL message with an empty ERRORS_TO produces a 201 created response, defaults to the account level ERRORS_TO
		Given I post a new EMAIL message with an empty ERRORS_TO produces an email

	@QC-3237 @QC-2239 
	Scenario: TMS posting a new EMAIL message with an invalid FROM_EMAIL produces a 422 response, not authorized to send on this account response.
		Given I post a new EMAIL message with an invalid FROM_EMAIL produces an error


#sms

        
    @QC-2234 @QC-1976
	Scenario: TMS posting a new SMS message with over 160 characters in the message body to a PHONE NUMBER produces a 422 Unprocessable response. 
		Given I post a new SMS message with too many characters
        
    @QC-2235 @QC-1976
	Scenario: TMS posting a new SMS message with under 160 characters in the message body to a PHONE NUMBER produces a 201 Created response.
		Given I post a new SMS message with the correct number of characters
        
    @QC-2236 @QC-1976
	Scenario: TMS posting a new SMS message with under 160 characters in the message body to a FORMATTED PHONE NUMBER produces a 201 Created response.
		Given I post a new SMS message with the correct number of characters to a formatted phone number
        
    @QC-2240 @QC-1976
	Scenario: TMS retrieve a message detail on a sent SMS 
		Given I post a new SMS message and retrieve the message details
        
    @QC-2241 @QC-1976
	Scenario: TMS retrieve a recipient detail on a sent SMS
		Given I post a new SMS message and retrieve the recipient details
        
    @QC-2422 @QC-1976
	Scenario: TMS posting a new SMS message to MULTIPLE RECIPIENTS
		Given I post a new SMS message to multiple recipients
          
    @QC-2476 @QC-1976
	Scenario: TMS posting a new SMS message with a body under 160 characters and NO PHONE NUMBER should produce an error.
		Given I post a new SMS message to an empty recipient
	
	@QC-2477 @QC-1976
	Scenario: TMS posting a new SMS message to MULTIPLE RECIPIENTS, 2 which are INVALID, produces 2 FAILED recipients.
		Given I post a new SMS message to invalid recipients I should not receive failed recipients	
    
    @QC-2478 @QC-1976
	Scenario: TMS posting a new SMS message with DUPLICATE phone numbers.
		Given I post a new SMS message with duplicate recipients
        
    @QC-3011 @QC-1976
	Scenario: TMS posting a new SMS message which contains special characters.
		Given I post a new SMS message which contains special characters

	@QC-3745 @QC-1976 
	Scenario: TMS rapid keyword sends while receiving one response
		Given I rapidly send a keyword via SMS

	#@QC-3744 @QC-1976 
	#Scenario: TMS sms to previx with invalid word
		#Given I send an SMS with an invalid word or command

	#@QC-3743 @QC-1976       
	#Scenario: TMS sms to shared account with invalid prefix
		#Given I send an SMS to a shared account with an invalid prefix



#voice


	@QC-2237 
	Scenario: TMS create a single voice message to multiple recipients
		Given I created a new voice message
		Then I should be able to verify that multiple recipients have received the message

	@QC-2237 
	Scenario: List and verify incoming voice messages
		Given I created a new voice message
		Then I should be able to verify the incoming message was received	

	@QC-2237 
	Scenario: Verify message detail
		Given I created a new voice message
		Then I should be able to verify details of the message


	








