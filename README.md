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


IPAWS Dev Setup
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
