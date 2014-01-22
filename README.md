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