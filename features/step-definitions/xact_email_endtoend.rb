#!/usr/bin/env ruby
# encoding: utf-8

require 'capybara'
require 'capybara/cucumber'
require 'rubygems'
require 'colored'
require 'awesome_print'
require 'mail'
require 'httpi'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# helper methods
module Helpy
  def initialize_variables
    Capybara.default_wait_time = 600

    @expected_subject = {}.store(1, Time.new.to_s + '::' + rand(100_000).to_s)
    @link_redirect_works = false
    @link_in_email = ''
    @expected_link = 'http://govdelivery.com'
    @wait_time = 5
    @conf_xact = configatron.accounts.email_endtoend.xact
    @conf_gmail = configatron.accounts.email_endtoend.gmail
  end

  def expected_link_prefix
    if ENV['XACT_ENV'] == 'qc'
      'http://test-links.govdelivery.com:80'
    elsif ENV['XACT_ENV'] == 'integration'
      'http://test-links.govdelivery.com:80'
    elsif ENV['XACT_ENV'] == 'stage'
      'http://stage-links.govdelivery.com:80/track'
    elsif ENV['XACT_ENV'] == 'prod'
      'https://odlinks.govdelivery.com'
    end
  end

  def path
    "#{@conf_xact.url}/messages/email"
  end

  def post_message(from_email=nil)
    next if dev_not_live?
    email_body = "This is a test for end to end email delivery. <a href=\\\"#{@expected_link}\\\">With a link</a>"
    XACTHelper.new.send_email(
      @conf_xact.user.email_address,
      @conf_xact.user.password,
      @expected_subject,
      email_body,
      @conf_gmail.imap.user_name,
      path,
      from_email,
      @conf_xact.user.token)
  end

  def get_emails
    message_list = Hash.new {}
    STDOUT.puts "Logging into Gmail IMAP looking for subject: #{@expected_subject}"
    # configatron blows up in Mail if we try to resolve components of it
    gmail_config = @conf_gmail.imap.to_h
    begin
      Mail.defaults do
        retriever_method :imap, gmail_config
      end

      emails = Mail.find(what: :last, count: 1000, order: :dsc)

      emails.each do |mail|
        mail.parts.map do |p|
          if p.content_type.include? 'text/html'
            message_list[mail.subject] = p.body.decoded
            @reply_to = get_field_value mail, 'Reply-To'
            @errors_to = get_field_value mail, 'Errors-To'
          end
        end
      end

    rescue => e
      STDOUT.puts "Error interacting with Gmail IMAP (will retry in #{@wait_time} seconds): #{e.message}"
      STDOUT.puts e.backtrace
    end

    message_list
  end

  # get the value of a field on the mail message
  def get_field_value(email, field_name)
    email.header.fields.each do |field|
      return field.value if field.name == field_name
    end
  end

  def test_link(link)
    if LinkTester.new.test_link(link['href'], @expected_link, expected_link_prefix)
      @link_redirect_works = true
      @link_in_email = link['href']
      STDOUT.puts "Link #{link['href']} redirects to #{@expected_link}".green
    else
      raise "Message #{@expected_subject} was found but link #{@link_in_email}didn't redirect".red unless @link_redirect_works
    end
  end

  def clean_inbox
    IMAPCleaner.new.clean_inbox(
      @conf_gmail.imap.address,
      @conf_gmail.imap.port,
      @conf_gmail.imap.enable_ssl,
      @conf_gmail.imap.user_name,
      @conf_gmail.imap.password)
    puts 'Cleaned inbox'.green
  end

  # Polls mail server for messages and validates message if found
  def validate_message
    next if dev_not_live?

    msg_found = false
    @wait_time = 5
    num_iterations = 120 # wait ten minutes if you retry every 5 seconds

    num_iterations.times do |iter|
      STDOUT.puts "Have waited #{@wait_time * iter} seconds".blue
      STDOUT.puts "Waiting for #{@wait_time} more seconds"
      sleep(@wait_time)

      message_list = get_emails

      if message_list[@expected_subject]
        msg_found = true
        STDOUT.puts "Message #{@expected_subject} found after #{@wait_time * iter} seconds".green
        doc = Nokogiri::HTML(message_list[@expected_subject])

        # validate link(s)
        if doc
          doc.css('a').each do |link|
            test_link link
          end
        end

        # validate from address information
        raise "Expected Reply-To of #{@expected_reply_to} but got #{@reply_to}" unless @reply_to == @expected_reply_to
        raise "Expected Errors-To of #{@expected_errors_to} but got #{@rerrors_to}" unless @errors_to == @expected_errors_to

        break
      end
    end # end while

    # validate message was found
    raise "Message #{@expected_subject} was not found in the inbox after #{@wait_time * num_iterations} seconds".red unless msg_found

    clean_inbox
  end
end
World(Helpy)

# steps
When(/^I POST a new EMAIL message to TMS using a non-default from address$/) do
  initialize_variables
  @expected_reply_to = @conf_xact.user.reply_to_address_two
  @expected_errors_to = @conf_xact.user.bounce_address_two
  post_message @conf_xact.user.from_address_two
end

When(/^I POST a new EMAIL message to TMS$/) do
  initialize_variables
  @expected_reply_to = @conf_xact.user.reply_to_address
  @expected_errors_to = @conf_xact.user.bounce_address

  post_message
end

Then(/^I go to Gmail to check for message delivery$/) do
  next if dev_not_live?
  validate_message
end
