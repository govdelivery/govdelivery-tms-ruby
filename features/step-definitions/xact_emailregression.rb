#!/bin/env ruby
# encoding: utf-8

require 'colored'
require 'json'
require 'awesome_print'
require 'httpi'
require 'base64'
require 'multi_xml'

module EmailDefaults
  MESSAGE = '<p><a href="http://www.cnn.com">Test</a>'
end

Mail.defaults do
  retriever_method :imap,
                   address:    'imap.gmail.com',
                   port:       993,
                   user_name:  EmailAdmin.new.mail_accounts,
                   password:  EmailAdmin.new.password,
                   enable_ssl: true
end

When(/^I get the list of from addresses/) do
  @addresses = client.from_addresses.get
end

Then(/^I should be able to list and read from addresses/) do
  raise "unable to get id from a from_address: #{@addresses}" unless @addresses.collection
  raise "unable to get id from a from_address: #{@addresses}" unless @addresses.collection.first.id
end

Given(/^I send an email from an account that has link tracking params configured$/) do
  @message = client.email_messages.build(body:                     EmailDefaults::MESSAGE,
                                         subject:                  "XACT-533-2 Email Test for link parameters #{Time.new}",
                                         from_email:               "#{EmailAdmin.new.from_email}")
  @message.recipients.build(email: EmailAdmin.new.mail_accounts)
  raise @message.errors.inspect unless @message.post
end

Then(/^those params should resolve within the body of the email I send$/) do
  a = 0
  until Mail.last != [] # checking to see if inbox is empty, and waiting until a message arrives
    sleep(10)
    STDOUT.puts 'waiting 10 seconds for emails to arrive'.green
    a += 1
    raise if a > 10
  end

  emails = Mail.last # establish emails var

  i = 0
  until emails.subject = EmailAdmin.new.subject # telling Mail what to look for
    STDOUT.puts 'waiting for email for 6 seconds'.blue
    sleep(6)
    i += 1

    raise 'The email didn\'t appear within 3 minutes'.red if i > 30
  end

  lines = emails.html_part.body.decoded # extracting all of the HTML out of the email since the email is MultiPart
  doc = Nokogiri::HTML.parse(lines) # Using Nokogiri to parse out the HTML to be something more readable
  URL = doc.css('p a').map { |link| link['href']}[0] # forcing an array mapping to the first <a href> within the first <p> tag since the email is built like that
  puts 'Link found goes to: '.green
  puts URL # outputting the extracted URL with the email for the sake of readability

  if URL.include? 'utf8=true'
    puts 'params found'.green
  else
    raise 'params not found'.red
  end
  Mail.find_and_delete(what: :all)
  puts 'Inbox email deleted'.green if Mail.all == []
end

Given(/^I am a TMS user and not an admin$/) do
  @request = HTTPI::Request.new
  @request.url = EmailAdmin.new.url
  @request.headers = {'Content-Type' => 'application/json', 'X-AUTH-TOKEN' => "#{EmailAdmin.new.non_admin}"}
end

Given(/^I am using a non-admin TMS client$/) do
  conf = configatron.accounts.email_endtoend
  @client = tms_client(conf)
end

Then(/^I should not be able to see the accounts endpoint$/) do
  @response = HTTPI.get(@request)

  if JSON.parse(@response.raw_body) == {'error' => 'forbidden'}
    puts 'Forbidden found, passing test'.green
  else
    raise 'Was able to view accounts as a user, test failed'.red
  end
end

#================2239 tests===============>