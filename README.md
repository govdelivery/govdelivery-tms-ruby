XACT
====
A Ruby on Rails application that sends SMS, email, and voice messages and reports on delivery statistics. Part of the GovDelivery TMS suite.

Creating a tag
==============

    git tag -a 1.4.0 -m 'creating another release'
    git push origin 1.4.0

Deploying
=========

    ./deploy.sh -e environment (defaults to qc)


IPAWS Setup
===============

    ./bin/vendors.rb -t IPAWSVendor -c 120082 -u "IPAWSOPEN_120082" -p "w0rk#8980" -r "2670soa#wRn" -j path/to/IPAWSOPEN_120082.jks
    # => Created IPAWS::Vendor id: 10000
    ./bin/accounts.rb -n "IPAWS Test Account" --ipaws_vendor 10000
    # => Created Account id: 10000
    ./bin/users.rb -a 10000 -e "insure@evotest.govdelivery.com" -p "fysucrestondoko" -s 0
    # => Created User id: 10000
    ./bin/tokens.rb --user 10000 --list
    # => Tokens:
    # => pzpL6p1m16yGqDXc6sBjaazPa1sTxVGq


Command Types
==============

To add a command\_type create a class that responds\_to `process\_response` and calls super within it such as:

    def process_response(account, params, http_response)
      cr = super
      build_message(account, params.from, cr.response_body) if cr.plaintext_body?
    end

Add the class to the directory app/models/command\_type, and registor the class in the app/models/command\_type/base.rb with:

    CommandType[:new_command]


Create a worker in app/workers/ by appending "Worker" to the name of the class of the new command_type suchas `NewCommandWorker`
