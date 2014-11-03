require 'tms_client'
require 'colored'
require 'httpi'
require 'json'
require 'awesome_print'
require 'twilio-ruby'

$bt = Hash.new
$bt.store(1, Time.new.to_s + "::" + rand(100000).to_s)


Given(/^I send an SMS to create a subscription on TMS$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should receive a SUBSCRIBE response$/) do
  pending # express the regexp above with the code you wish you had
end

And(/^a subscription should be created$/) do
  pending # express the regexp above with the code you wish you had
end



Given(/^I send an SMS to opt out of receiving TMS messages$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should receive a STOP response$/) do
  pending # express the regexp above with the code you wish you had
end

And(/^a my subscription should be removed$/) do
  pending # express the regexp above with the code you wish you had
end