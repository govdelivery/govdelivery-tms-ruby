# Xact Test Accounts

End-to-End tests require accounts on Xact. By convention, each test (a scenario described in a .feature file) has its own
Xact account configured for that test's needs on each testing environment. These accounts were created via Rake tasks, and
can easily be recreated when needed.

All test accounts use Shared SMS Vendors, and have an sms_prefix based on the test name. When required, test accounts will
also have appropriate Transformers configured.

## Common Vendors

The Email/SMS/Voice vendors used by Xact test accounts are generally shared by many test accounts. The following common
vendors exist on each testing environment. Again, these accounts were created via Rake tasks.


| Email Vendor Name                             | Notes                                                             | 
|--------------------------------------------   |----------------------------------------------------------------   |
| Test - Shared Loopback Email Vendor           | Makes no attempt to actually send emails.                         |
|                                               | Has magic recipient email addresses to force recipient states.    |
| ODM Sender --or-- TMS Extended Sender         | Live sender of email.                                             |
|                                               | ODM Sender on QC, TMS Extended Sender on integration and stage.   |


*All SMS Vendors are Shared vendors (.shared? == true)*

| SMS Vendor Name                              	        | Notes                                                           	        |
|--------------------------------------------	        |---------------------------------------------------------------------------|
| Test - Shared Loopback SMS Vendor          	        | Makes no attempt to actually send SMSs.                                   |
|                                                       | Has magic recipient phone numbers to force recipient states.              |
| Test - Shared Twilio Valid Test SMS Vendor 	        | Uses Twilio test credentials. Doesn't actually send messages.             |
|                                                       | Only phone number from which a 'valid' transaction can occur.             |                                                                                                                                                      	|
| Test - Shared Twilio Invalid Number Test SMS Vendor   | Uses Twilio test credentials. Doesn't actually send messages.             |
|                                                       | Transactions from this number return invalid phone number from Twilio.    |
| Test - Shared Live SMS Vendor                         | Can actually send SMSs. Each environment has it's own Live number.        |


| Voice Vendor Name                             | Notes                                                             |
|--------------------------------------------   |-------------------------------------------------------------------|
| Test - Shared Loopback Voice Vendor           | Makes no attempt to actually make a call.                         |
|                                               | Has magic recipient phone numbers to force recipient states.      |
| Test - Shared Live Voice Vendor               | Can actually send SMSs. Each environment has it's own Live number.|

## Creating A New Account

A new test should start with the creation of a new account on each environment. Creating a new account should be done by
creating a new rake task in xact/lib/tasks/endtoend_test_accounts. The simpliest test accounts (e.g. sms_2way_static.rake)
shouldn't do much more than:

- require 'rake_helper'
- call a rake task to create/update common vendors
- call the create_test_account function with the name of the test and vendor config info

More complicated test accounts (e.g. sms_2way_bart.rake) should modify and save the account created by create_test_account

Run the rake task on each environment once it has been created. The rake task will print some configuration information (account email
address, token) that should be copied to a configuration file for the test.

# Test Configuration

The End-to-End tests use [Configatron](https://github.com/markbates/configatron) to store required configuration 
information required. Common confirguration settings (xact url, config for common vendors) are set in ./support/env.rb,
while test specific configurations are set in test specific files in ./support/config.

## Top Level Configatron Objects

- configatron.accounts - Namespace for all test account configurations
- configatron.xact - Config info for the Xact instance being used during tests
- configatron.test_support - Config for the 
    [Xact End-to-End Test Support application](http://dev-scm.office.gdi/bill.bushey/xact_dumb_webhooks) 
    that creates endpoints and receives payloads
- configatron.sms_vendors - Configuration for common Xact SMS Vendors shared by accounts
- configatron.voice_vendors - Configuration for common Xact Voice Vendors shared by accounts

### configatron.accounts Conventions

By convention, any configuration object under configatron.accounts should have all configuration info required to
run the test it represents. That includes a .xact object, and sms/voice/email objects for any common vendors that
the test uses. Tests generally expect to get a configuration object (e.g. conf)from configatron.accounts, and expect 
to be able to do:

    conf.xact.url               # Oh boy, a URL!
    conf.xact.user.token        # That thing that let's the test do stuff!
    conf.sms.phone.number       # Something to text to Xact to!
    etc...

### Set Config of Shared Vendors

Setting the email/voice/sms vendor configuration on accounts that use a common vendor is simply. 
Just set the email/voice/sms attribute of the account's config to a clone of the common vendor's configuration.


    configatron.accounts.funky_test.voice = configatron.voice_vendors.loopbacks.clone()
    configatron.accounts.funky_test.sms = configation.sms_vendors.loopbacks.clone()

# Fuctions

- magic_addresses - returns magic addresses for the loopback workers that will force specific states on recipients.
  Type of address is dependant on the message type provided. If :email, magic email addresses are returned. If :sms or :voice,
  magic phone numbers are returned.