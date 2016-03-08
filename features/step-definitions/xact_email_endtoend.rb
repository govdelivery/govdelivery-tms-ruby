#!/usr/bin/env ruby
# encoding: utf-8

require 'awesome_print'
require 'capybara'
require 'capybara/cucumber'
require 'colored'
require 'govdelivery-tms'
require 'mail'
require 'mechanize'
require 'rubygems'

# helper methods
module Helpy
  def initialize_variables
    Capybara.default_wait_time = 600

    @expected_subject = 'xact_email_end_to_end - ' + Time.new.to_s + '::' + rand(100_000).to_s
    @link_redirect_works = false
    @expected_link = 'http://govdelivery.com'
    @conf_xact = configatron.accounts.email_endtoend.xact
    @conf_gmail = configatron.accounts.email_endtoend.gmail

    imap_config = @conf_gmail.imap.to_h
    Mail.defaults do
      retriever_method :imap, imap_config
    end
  end

  def expected_link_prefix
    case ENV['XACT_ENV']
      when 'qc'
        'http://qc-links.govdelivery.com:80'
      when 'integration'
        'http://int-links.govdelivery.com:80'
      when 'stage'
        'http://stage-links.govdelivery.com:80/track'
      when 'prod'
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

  def get_emails(expected_subject)
    STDOUT.puts "Checking Gmail IMAP for subject \"#{@expected_subject}\""
    emails = Mail.find(what: :last, count: 1000, order: :dsc)
    STDOUT.puts "Found #{emails.size} emails"
    STDOUT.puts "subjects:\n\t#{emails.map(&:subject).join("\n\t")}" if emails.any?

    if (mail = emails.detect { |mail| mail.subject == expected_subject })
      [mail.html_part.body.decoded,
       mail.header.fields.detect { |field| field.name == 'Reply-To' }.value,
       mail.header.fields.detect { |field| field.name == 'Errors-To' }.value]
    else
      nil
    end

  rescue => e
    STDOUT.puts "Error interacting with Gmail IMAP: #{e.message}"
    STDOUT.puts e.backtrace
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
    condition = proc do
      # get message
      body, reply_to, errors_to = get_emails(@expected_subject)
      next if body.nil?

      # validate from address information
      raise "Expected Reply-To of #{@expected_reply_to} but got #{reply_to}" if @expected_reply_to && reply_to != @expected_reply_to
      raise "Expected Errors-To of #{@expected_errors_to} but got #{errors_to}" if @expected_errors_to && errors_to != @expected_errors_to

      # validate link is present
      if @expected_link &&
        (href = Nokogiri::HTML(body).css('a').
          map { |link| link['href'] }.
          detect { |href| test_link(href, @expected_link, expected_link_prefix) })
        puts "Link #{href} redirects to #{@expected_link}".green
        return true
      end

      raise "Message #{@expected_subject} was found but no links redirect to #{@expected_link}".red
    end
    backoff_check(condition, "find message #{@expected_subject}")
  ensure
    clean_inbox
  end

  def test_link(link_url, expected, expected_prefix)
    Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
      agent.redirect_ok          = false
    end.get(link_url) do |page| # retrieve link_url from agent
      page.forms.any? { |f| ((f['url'].eql? expected) && (link_url.start_with? expected_prefix)) }
    end
  end

end
World(Helpy)

When(/^I POST a new EMAIL message to TMS$/) do
  @expected_reply_to = @conf_xact.user.reply_to_address
  @expected_errors_to = @conf_xact.user.bounce_address

  post_message
end

# steps
Given(/A non-admin user/) do
  initialize_variables
end

Given(/An admin user/) do
  initialize_variables
  unless (@conf_xact.user.token = ENV['XACT_EMAILENDTOEND_ADMIN_TOKEN'])
    raise "ENV['XACT_EMAILENDTOEND_ADMIN_TOKEN'] is not set"
  end
end

When(/^I POST a new EMAIL message to TMS using a non-default from address$/) do
  @expected_reply_to = @conf_xact.user.reply_to_address_two
  @expected_errors_to = @conf_xact.user.bounce_address_two
  post_message from_email: @conf_xact.user.from_address_two
end

When(/^I POST a new EMAIL message to TMS using a random from address$/) do
  @expected_reply_to = "product-noexist@evotest.govdelivery.com"
  @expected_errors_to = "product-noexist@evotest.govdelivery.com"
  post_message from_email: "product-noexist@evotest.govdelivery.com"
end

When(/^I POST a new EMAIL message to TMS with long macro replacements$/) do
  post_message body: %Q|[[MAC1]]\n\n[[MAC2]]\n\n<a href="#{@expected_link}">With a link</a>|, macros: {'MAC1' => 'a'*800, 'MAC1' => 'b'*150}
end

Then(/^I go to Gmail to check for message delivery$/) do
  next if dev_not_live?
  validate_message
end
