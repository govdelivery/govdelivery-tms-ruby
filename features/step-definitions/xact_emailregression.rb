#!/bin/env ruby
# encoding: utf-8

require 'colored'
require 'json'
require 'awesome_print'
require 'httpi'
require 'base64'
require 'multi_xml'

Given(/^A Gmail recipient/) do
  Mail.defaults do
    retriever_method :imap,
                     address:    'imap.gmail.com',
                     port:       993,
                     user_name:  TmsClientManager.mail_accounts,
                     password:   TmsClientManager.password,
                     enable_ssl: true
  end
end

When(/^I get the list of from addresses/) do
  @addresses = TmsClientManager.voice_client.from_addresses.get
end

Then(/^I should be able to list and read from addresses/) do
  raise "unable to get id from a from_address: #{@addresses}" unless @addresses.collection
  raise "unable to get id from a from_address: #{@addresses}" unless @addresses.collection.first.id
end

Given(/^I send an email from an account that has link tracking params configured$/) do
  @message = TmsClientManager.voice_client.email_messages.build(body:       '<p><a href="http://www.cnn.com">Test</a>',
                                                                subject:    TmsClientManager.subject,
                                                                from_email: TmsClientManager.from_email)
  @message.recipients.build(email: TmsClientManager.mail_accounts)
  raise @message.errors.inspect unless @message.post
end

Then(/^those params should resolve within the body of the email I send$/) do
  condition = proc do
    STDOUT.puts "Checking Gmail IMAP for subject \"#{TmsClientManager.subject}\""
    emails = Mail.find(what: :last, count: 1000, order: :dsc)
    STDOUT.puts "Found #{emails.size} emails"
    STDOUT.puts "subjects:\n\t#{emails.map(&:subject).join("\n\t")}" if emails.any?

    if (message = emails.detect { |mail| mail.subject == TmsClientManager.subject })
      doc = Nokogiri::HTML.parse(message.html_part.body.decoded) # Using Nokogiri to parse out the HTML to be something more readable
      url = doc.css('p a').map { |link| link['href'] }[0] # forcing an array mapping to the first <a href> within the first <p> tag since the email is built like that
      puts "Link found goes to: #{url}".green

      if url.include? 'utf8=true'
        puts "params found in #{url}".green
      else
        raise "params not found in #{url}".red
      end
    end
  end

  begin
    backoff_check(condition, 'looking for link params in email body')
  ensure
    Mail.find_and_delete(what: :all)
    puts 'Inbox email deleted'.green if Mail.all == []
  end
end

Given(/^I am a TMS user and not an admin$/) do
  @request         = HTTPI::Request.new
  @request.url     = TmsClientManager.url
  @request.headers = {'Content-Type' => 'application/json', 'X-AUTH-TOKEN' => TmsClientManager.non_admin_token}
end

Given(/^I am using a non-admin TMS client$/) do
  @client = TmsClientManager.from_configatron(configatron.accounts.email_endtoend)
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