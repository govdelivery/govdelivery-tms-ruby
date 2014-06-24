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

### Keywords:VendorDefault

-   text "gibberish" to GOV311
-   responds with help text by default

### Keywords::VendorHelp

-   text "help" or "info" to GOV311
-   responds with help text by default

### Keywords::VendorStop

-   text any of stop,stopall,unsubscribe,cancel,end,quit to GOV311
-   responds with stop text by default
-   phone number will be added to vendor's blacklist (stop requests table)
-   each command on each account's stop keyword (Keywords::AccountStop) will be executed (to remove from dcm)

### Keywords::VendorStart

-   text "start" or "yes" to GOV311
-   responds with start text by default
-   phone number will be removed from vendor's blacklist (stop requests table)

### Keywords::AccountDefault

Here, BART is used but any prefix will work

-   text "bart gibberish" to GOV311
-   text "gibberish" to private short code or number
-   responds with help text by default
-   the response text should be removed if a forward command is created (only forward command responds)

### Keywords::AccountHelp

-   text "bart help" to GOV311
-   text "help" to private short code or number
-   responds with help text by default

### Keywords::AccountStop

-   text "bart stop" to GOV311
-   text "stop" to private short code or number
-   requires the addition of commands upon account creation (e.g.: dcm unsubscribe)
-   see DCM Unsubscribe Command below

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
      expected_content_type: 'text/html', #allows something other than text/plain - the default
      from_param_name: 'user',    # the name of the phone number parameter - default 'from'
      sms_body_param_name: 'req', # lets say the text body is "12th" - default 'sms_body'
    }
    # these params will result in a request of: http://tomale.com?user="5555555555"&req="12th"
    # and only a 200ish response of type 'text/html' (and less than 500 chars) will be sent to the user number

    # to foward everything use the default keyword, it will catch anything that doesn't match existing keywords
    account.create_command('Keywords::AccountDefault', command_type: 'forward', params: forward_params)

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

it makes sense to put this command on keyword: "Keywords::AccountStop"
but it can be put on other custom keywords

it must be created manually for every account

it will delete the subscription from the DCM account

    # must be dcm_account_codes PLURAL!
    account.create_command!('Keywords::AccountStop',
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
