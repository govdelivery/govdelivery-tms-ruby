#!/usr/bin/env ruby
# encoding: utf-8

World(Helpy)

When(/^I POST a new EMAIL message to TMS$/) do
  @expected_reply_to = @conf_xact.user.reply_to_address
  @expected_errors_to = @conf_xact.user.bounce_address
  @expected_from_name = @conf_xact.user.email_address

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
  @expected_from_name = "#{@conf_xact.user.from_name_two} <#{@conf_xact.user.from_address_two}>"
  post_message from_email: @conf_xact.user.from_address_two
end

When(/^I POST a new EMAIL message to TMS with message\-level from name using a from address with a from name$/) do
  @expected_reply_to = @conf_xact.user.reply_to_address_two
  @expected_errors_to = @conf_xact.user.bounce_address_two
  @expected_from_name = "message-level from name <#{@conf_xact.user.from_address_two}>"

  post_message from_email: @conf_xact.user.from_address_two, from_name: 'message-level from name'
end

When(/^I POST a new EMAIL message to TMS using a random from address$/) do
  @expected_reply_to = "product-noexist@evotest.govdelivery.com"
  @expected_errors_to = "product-noexist@evotest.govdelivery.com"
  post_message from_email: "product-noexist@evotest.govdelivery.com"
end

When(/^I POST a new EMAIL message to TMS with long macro replacements$/) do
  @expected_from_name = "#{@conf_xact.user.email_address}"
  post_message body: %|[[MAC1]]\n\n[[MAC2]]\n\n<a href="#{@expected_link}">With a link</a>|, macros: {'MAC1' => 'a' * 800, 'MAC1' => 'b' * 150}
end

When(/^I POST a new EMAIL message to TMS with a message-level from name$/) do
  @expected_from_name = "message-level from name <#{@conf_xact.user.email_address}>"
  @expected_reply_to = @conf_xact.user.reply_to_address
  @expected_errors_to = @conf_xact.user.bounce_address
  post_message from_name: 'message-level from name'
end

Then(/^I go to Gmail to check for message delivery$/) do
  next if dev_not_live?
  passed = false

  begin
    GovDelivery::Proctor.backoff_check(10.minutes, "find message #{@expected_subject}") do
      # get message
      body, reply_to, errors_to, from_name = get_emails(@expected_subject)
      unless body.nil?
        # validate from address information
        raise "Expected Reply-To of #{@expected_reply_to} but got #{reply_to}" if @expected_reply_to && (reply_to != @expected_reply_to)
        raise "Expected Errors-To of #{@expected_errors_to} but got #{errors_to}" if @expected_errors_to && (errors_to != @expected_errors_to)
        raise "Expected From of #{@expected_from_name} but got #{from_name}" if @expected_from_name && (from_name != @expected_from_name)

        # validate link is present
        if @expected_link &&
           (href = Nokogiri::HTML(body).css('a')
                   .map { |link| link['href']}
                   .detect { |inner_href| test_link(inner_href, @expected_link, expected_link_prefix)})
          log.info("Link #{href} redirects to #{@expected_link}".green)
          passed = true
        else
          raise "Message #{@expected_subject} was found but no links redirect to #{@expected_link}".red
        end
      end
    end
  ensure
    clean_inbox
  end
  passed
end
