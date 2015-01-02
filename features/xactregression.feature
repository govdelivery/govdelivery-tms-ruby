Feature: XACT Full Regression
      
    @QC-2453 @QC-2440 @DONE
	Scenario: TMS configure a text response for an SMS keyword under 160 characters.
		Given I create a new keyword with a text response
        Then I should be able to create and delete the keyword

    @QC-2496 @QC-2440 @DONE
	Scenario: TMS configure a text response for an SMS keyword over 160 characters.
		Given I attempt to create a keyword with a response text over 160 characters

    @QC-2492 @QC-2440 @DONE
	Scenario: TMS creating and deleting Forward commands for a Keyword.
		Given I create a new forward keyword and command
        And I should be able to delete the forward keyword

    @QC-2488 @QC-2440 @DONE
	Scenario: TMS creating and deleting Subscribe, Unsubscribe commands for a Keyword. 
		Given I create a new subscribe keyword and command
        And I should be able to delete the subscribe keyword
        Given I create a new unsubscribe keyword and command
        And I should be able to delete the unsubscribe keyword

    @QC-2452 @QC-2440 @DONE
	Scenario: TMS creating and deleting Subscribe commands for a Keyword when the account is invalid.
		Given I create a keyword and command with an invalid account code
        Then I should receive an error


#QC-2239 based tests.      
#QC environment 

    @QC-2456 @QC-2239
	Scenario: TMS verify the ability to disable open and click tracking in my EMAIL sends
		Given I verify the ability to disable open and click tracking in my EMAIL sends

    @QC-2520 @QC-2239
	Scenario: TMS posting a new EMAIL with message and recipient MACROS
		Given I post a new EMAIL with message and recipient MACROS
       
    @QC-2292 @QC-2239 @DONE
	Scenario: TMS posting a new EMAIL message with an empty BODY produces a 422 error
		Given I post a new EMAIL message with an empty BODY produces an error
        
    @QC-2294 @QC-2239 @DONE
	Scenario: TMS posting a new EMAIL message with an empty SUBJECT produces a 422 error
		Given I post a new EMAIL message with an empty SUBJECT produces an error
        
    @QC-2295 @QC-2239 @DONE
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
        
    @QC-2472 @QC-2239 @DONE
	Scenario: TMS posting a new EMAIL message with 1 VALID and 1 INVALID RECIPIENT produces a 201 created response and a failed recipient
		Given I post a new EMAIL message with a VALID and INVALID RECIPIENT produces an email

    @QC-3227 @QC-2239 @DONE
	Scenario: TMS posting a new EMAIL message with an empty FROM_EMAIL produces a 422 response
		Given I post a new EMAIL message with an empty FROM_EMAIL produces an error

    @QC-3233 @QC-2239 @DONE
	Scenario: TMS posting a new EMAIL message with an empty REPLY_TO produces a 201 created response, defaults to the account level FROM_ADDRESS.
		Given I post a new EMAIL message with an empty REPLY_TO produces an email

    @QC-3234 @QC-2239 @DONE
	Scenario: TMS posting a new EMAIL message with an empty ERRORS_TO produces a 201 created response, defaults to the account level ERRORS_TO
		Given I post a new EMAIL message with an empty ERRORS_TO produces an email

	@QC-3237 @QC-2239 @DONE
	Scenario: TMS posting a new EMAIL message with an invalid FROM_EMAIL produces a 422 response, not authorized to send on this account response.
		Given I post a new EMAIL message with an invalid FROM_EMAIL produces an error









