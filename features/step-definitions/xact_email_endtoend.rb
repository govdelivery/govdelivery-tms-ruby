#!/usr/bin/env ruby
# encoding: utf-8

require 'capybara'
require 'capybara/cucumber'
require 'rubygems'
require 'colored'
require 'awesome_print'
require 'mail'
require 'govdelivery-tms'

# helper methods
module Helpy
  def initialize_variables
    Capybara.default_wait_time = 600

    @expected_subject = 'xact_email_end_to_end - ' + Time.new.to_s + '::' + rand(100_000).to_s
    @link_redirect_works = false
    @link_in_email = ''
    @expected_link = 'http://govdelivery.com'
    @wait_time = 5
    @conf_xact = configatron.accounts.email_endtoend.xact
    @conf_gmail = configatron.accounts.email_endtoend.gmail
  end

  def expected_link_prefix
    if ENV['XACT_ENV'] == 'qc'
      'http://qc-links.govdelivery.com:80'
    elsif ENV['XACT_ENV'] == 'integration'
      'http://int-links.govdelivery.com:80'
    elsif ENV['XACT_ENV'] == 'stage'
      'http://stage-links.govdelivery.com:80/track'
    elsif ENV['XACT_ENV'] == 'prod'
      'https://odlinks.govdelivery.com'
    end
  end

  def api_root
    @conf_xact.url
  end

  def messages_path
    '/messages/email'
  end

  def path
    api_root+messages_path
  end

  def post_message(opts={})
    next if dev_not_live?
    opts[:body] ||= %Q|This is a test for end to end email delivery. <a href="#{@expected_link}">With a link</a>|
    email_message = GovDelivery::TMS::Client.
      new(@conf_xact.user.token, api_root: api_root).
      email_messages.build(
      from_email: opts[:from_email],
      macros:     opts[:macros],
      body:       opts[:body],
      subject:    @expected_subject
    )
    email_message.recipients.build(email: @conf_gmail.imap.user_name)
    email_message.post!
    response = email_message.response
    ap response.status
    ap response.headers
    ap response.body
  end

  def get_emails
    message_list = {}
    STDOUT.puts "Logging into Gmail IMAP looking for subject: #{@expected_subject}"
    # configatron blows up in Mail if we try to resolve components of it
    gmail_config = @conf_gmail.imap.to_h
    begin
      Mail.defaults do
        retriever_method :imap, gmail_config
      end

      emails = Mail.find(what: :last, count: 1000, order: :dsc)
      STDOUT.puts "Found #{emails.size} emails"

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
    email.header.fields.detect { |field| field.name == field_name }.value
  end

  def test_link(link)
    @link_in_email = link['href']
    if LinkTester.new.test_link(link['href'], @expected_link, expected_link_prefix)
      @link_redirect_works = true
      STDOUT.puts "Link #{link['href']} redirects to #{@expected_link}".green
    else
      raise "Message #{@expected_subject} was found but link #{@link_in_email} didn't redirect to #{@expected_link}".red unless @link_redirect_works
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

    begin
      msg_found      = false
      @wait_time     = 5
      120.times do |iter| # wait ten minutes if you retry every 5 seconds
        STDOUT.puts "Have waited #{@wait_time * iter} seconds".blue
        STDOUT.puts "Waiting for #{@wait_time} more seconds"
        sleep(@wait_time)

        message_list = get_emails

        if message_list[@expected_subject]
          msg_found = true
          STDOUT.puts "Message #{@expected_subject} found after #{@wait_time * iter} seconds".green

          # validate link(s)
          if doc = Nokogiri::HTML(message_list[@expected_subject])
            doc.css('a').each do |link|
              test_link link
            end
          end

          break
          # validate from address information
          raise "Expected Reply-To of #{@expected_reply_to} but got #{@reply_to}" unless @reply_to == @expected_reply_to
          raise "Expected Errors-To of #{@expected_errors_to} but got #{@rerrors_to}" unless @errors_to == @expected_errors_to
        end
      end # end while

      # validate message was found
      raise "Message #{@expected_subject} was not found in the inbox after #{@wait_time * (iter+1)} seconds".red unless msg_found

    ensure
      clean_inbox
    end
  end
end
World(Helpy)

When(/^I POST a new EMAIL message to TMS$/) do
  initialize_variables
  @expected_reply_to = @conf_xact.user.reply_to_address
  @expected_errors_to = @conf_xact.user.bounce_address

  post_message
end

# steps
Given(/I am an admin/) do
  initialize_variables
  unless ENV['XACT_EMAILENDTOEND_ADMIN_TOKEN']
    raise "ENV['XACT_EMAILENDTOEND_ADMIN_TOKEN'] is not set"
  end
  @conf_xact.user.token = ENV['XACT_EMAILENDTOEND_ADMIN_TOKEN']
end

When(/^I POST a new EMAIL message to TMS using a non-default from address$/) do
  initialize_variables
  @expected_reply_to = @conf_xact.user.reply_to_address_two
  @expected_errors_to = @conf_xact.user.bounce_address_two
  post_message from_email: @conf_xact.user.from_address_two
end

When(/^I POST a new EMAIL message to TMS using a random from address$/) do
  initialize_variables
  @expected_reply_to = @conf_xact.user.reply_to_address_two
  @expected_errors_to = @conf_xact.user.bounce_address_two
  post_message from_email: "no@exist.com"
end

When(/^I POST a new EMAIL message to TMS with long macro replacements$/) do
  initialize_variables
  post_message body: "[[MAC1]]\n\n[[MAC2]]", macros: {'MAC1' => 'a'*800, 'MAC1' => 'b'*150, }
end

Then(/^I go to Gmail to check for message delivery$/) do
  next if dev_not_live?
  validate_message
end
