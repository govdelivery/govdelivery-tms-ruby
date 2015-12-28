XACT
====
A Ruby on Rails application that sends SMS, email, and voice messages and reports on delivery statistics. Part of the GovDelivery TMS suite.

Creating a tag
==============

    git tag -a 1.4.0 -m 'creating another release'
    git push origin 1.4.0

Deploying
=========

    ./deploy.sh  (defaults to master and qc)
    ./deploy.sh -e int-ep --vc-tag 1.4.0

IPAWS Setup
===============

(see ipaws notes below)

    ./bin/vendors.rb -t IPAWSVendor -c 120082 -u "IPAWSOPEN_120082" -p "w0rk#8980" -r "2670soa#wRn" -j path/to/IPAWSOPEN_120082.jks
    # => Created IPAWS::Vendor id: 10000
    ./bin/accounts.rb -n "IPAWS Test Account" --ipaws_vendor 10000
    # => Created Account id: 10000
    ./bin/users.rb -a 10000 -e "insure@evotest.govdelivery.com" -p "fysucrestondoko" -s 0
    # => Created User id: 10000
    ./bin/tokens.rb --user 10000 --list
    # => Tokens:
    # => pzpL6p1m16yGqDXc6sBjaazPa1sTxVGq

Monitoring Setup
=================
For environments from qc to production, a "Monitoring" account should
be created that can send emails, text, and voice. This is similar to a
test account, but exists for the sole purpose of monitoring the
platform.

    # Create the account
        ./bin/accounts.rb -n "GovDelivery Monitoring Account" --email_vendor=10000 --sms_vendor=10001 --voice_vendor=10001 --sms_prefix='MONITOR'

    # Create user and token
	./bin/users.rb -a ACCOUNTID -e 'nagios@govdelivery.com' -s 0 -p 'SOMEpasSWORD'

    # List token
	./bin/tokens.rb -u USERID --list


ipaws notes:
The zip file we receive will be password encrypted by a windows program called pkzip.
If on a mac, you will need to install p7zip to unzip this file and retreive the .jks file.

    brew install p7zip
    7za x filename.zip


Two-Way SMS
===========

## Special Keywords

-   must be edited in the console
-   are created automatically
-   response text can be changed
-   commands can be added to all keywords including the special ones
-   there is no AccountStart keyword

Here, GOV311 is used but any short code of a shared vendor will work

### Vendors

-   vendors can have their custom responses modified via help_text, stop_text, and start_text
-   vendors will call their associated account's stop and start commands when texted 'stop' or 'start'
-   non-shared vendors will delegate all special keywords to their single account

### Accounts with prefixes (examples)

#### 'default'

-   text "[prefix] gibberish" to GOV311
-   responds with help text by default or vendor help_text if set
-   update default_keyword.response_text to change
-   account's default keyword commands will be executed

#### 'help'

-   text "[prefix] help" or "[prefix] info" to GOV311
-   responds with help text by default or vendor help_text if set
-   update help_keyword.response_text to change
-   account's help keyword commands will be executed

#### 'stop'

-   text any of stop,stopall,unsubscribe,cancel,end,quit with a prefix to GOV311
-   responds with stop text by default or vendor stop_text if set
-   phone number will be added to account's blacklist (stop requests table)
-   update stop_keyword.response_text to change
-   account's stop keyword commands will be executed

#### 'start'

-   text "start" or "yes" with prefix to GOV311
-   responds with start text by default or vendor start_text if set
-   phone number will be removed from account's blacklist (stop requests table)
-   update start_keyword.response_text to change
-   account's start keyword commands will be executed

## Custom Keywords

### With Plain Response - no command

    account.keywords.create(name: 'hot', response_text: 'tomale')

### With Forward Command

the response from the 3rd party site will be relayed to the phone through twilio

the expected content type can be set, but text/plain is the default

if more than 500 characters, or status code above 299 are returned the action will fail

    account.create_command('hot', command_type: 'forward', params: {url: 'tomale.com', http_method: 'get'})
    # remember to be sure to remove the repsonse_text
    account.keywords('hot').update_attribute :response_text, nil

    # forward everything:
    forward_params = {
      url: 'tomale.com',
      http_method: 'get',
      from_param_name: 'user',    # the name of the phone number parameter - default 'from'
      sms_body_param_name: 'req', # lets say the text body is "12th" - default 'sms_body'
    }
    # these params will result in a request of: http://tomale.com?user="5555555555"&req="12th"
    # and only a 200ish response of type 'text/html' (and less than 500 chars) will be sent to the user number

    # to foward everything use the default keyword, it will catch anything that doesn't match existing keywords
    account.create_command('default', command_type: 'forward', params: forward_params)

    # be sure to remove the response text because the forward command will respond
    account.default_keyword.update_attribute :response_text, nil

### With DCM Subscribe Command

Creates a subscription in DCM

an email subscription will be created if an email address is given as an
argument:  "subscribe me@there.com"

a wireless subscription will be created if no argument is given

    # must be dcm_account_code SINGULAR!
    account.create_command('subscribe',
                           command_type: 'dcm_subscribe', params: {dcm_account_code: 'xyz', dcm_topic_codes: ['abc']} )
    # if the account has multiple dcm_account_codes create another command to subscribe to both at once
    account.create_command('subscribe',
                           command_type: 'dcm_subscribe', params: {dcm_account_code: 'uvw', dcm_topic_codes: ['def']} )

### With DCM Unsubscribe Command

it makes sense to put this command on keyword: "stop"
but it can be put on other custom keywords

it must be created manually for every account

it will delete the subscription from the DCM account

    # must be dcm_account_codes PLURAL!
    account.create_command!('stop',
                            command_type: 'dcm_unsubscribe', params: {dcm_account_codes: ['xyz','uvw'] } )
    account.create_command!('désabonner',
                            command_type: 'dcm_unsubscribe', params: {dcm_account_codes: ['xyz','uvw'] } )


Adding a Command Type
=====================

To add a command type create a class that responds to `process\_response` and calls super within it such as:

    def process_response(account, params, http_response)
      cr = super
      build_message(account, params.from, cr.response_body) if cr.plaintext_body?
    end

Add the class to the directory `app/models/command\_type`, and registor the class in the `app/models/command\_type/base.rb` with:

    CommandType[:new_command]


Create a worker in `app/workers/` by appending "Worker" to the name of the class of the new command_type suchas `NewCommandWorker`

The worker should use the CommandParameters that are serialized in the database on command.params combined with parameters from
the twilio request controller

Generating a TMS Extended jar
=============================
```
rake odm:jar
```
will generate lib/tms_extended.jar from config/TMSExtended.wsdl


Cucumber Tests
==============

    XACT_ENV=qc bundle exec cucumber --verbose features/xact_endtoend.feature

