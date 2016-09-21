#########################################
# Given
#########################################

Given(/^I create an email( with no recipients)?$/) do |recipients|
  @message = TmsClientManager.non_admin_client.email_messages.build(body:       'Test',
                                                                    subject:    'Regression Test email send',
                                                                    from_email: TmsClientManager.from_email)
  if recipients != " with no recipients"
    @message.recipients.build(email: 'regressiontest2@sink.govdelivery.com')
  end
end

Given(/^I send an email from an account that has link tracking params configured$/) do
  @subject = "XACT-533-2 Email Test for link parameters #{Time.now}"
  @message = TmsClientManager.admin_client.email_messages.build(body:       '<p><a href="http://www.cnn.com">Test</a>',
                                                                subject:    @subject,
                                                                from_email: TmsClientManager.from_email)
  @message.recipients.build(email: configatron.gmail.address)
  @message.post!
end

Given(/^A Gmail recipient/) do
  Mail.defaults do
    retriever_method :imap,
                     address:    'imap.gmail.com',
                     port:       993,
                     user_name:  configatron.gmail.address,
                     password:   configatron.gmail.password,
                     enable_ssl: true
  end
end

Given(/^I am using a non-admin TMS client$/) do
  @client = TmsClientManager.from_configatron(@conf_xact.token)
end

#########################################
# When
#########################################

When(/^I add the macro '(.*)' => '(.*)'$/) do |key,value|
  @message.macros = {key => value}
end

When(/^I get the list of from addresses/) do
  @addresses = TmsClientManager.non_admin_client.from_addresses.get
end

When(/^I set the body to '(.*)'$/) do |body|
  @message.body = body
end

When(/^I set the message_type_code to '(.*)'$/) do |message_type_code|
  @message.message_type_code = message_type_code
end

Given(/^an email message exists with a message_type_code '(.*)'$/) do |code|
  step 'I create an email'
  step "I set the message_type_code to '#{code}'"
  step 'I send the email'
end

When(/^I add recipient '(.*)$/) do |recipient|
  @message.recipients.build(email: recipient)
end

When(/^I set the subject to '(.*)'$/) do |subject|
  @message.subject = subject
end

When(/^I disable Click tracking$/) do
  @message.click_tracking_enabled = false
end

When(/^I disable Open tracking$/) do
  @message.open_tracking_enabled = false
end
When(/^I set the from email to '(.*)'$/) do |from_email|
  @message.from_email = from_email
end

#########################################
# Then
#########################################

Then(/^(Open|Click) tracking should be disabled$/) do |type|
  raise 'click tracking not disabled'.red unless @message.get.response.body[type.downcase + '_tracking_enabled'] == false
end

Then(/^the message should have macro '(.*)' => '(.*)'$/) do |key, value|
  raise 'no macros found'.red unless @message.get.response.body['macros'] = "{'#{key}'=>'#{value}'}"
end

Then(/^the message should have "(.*)" set to "(.*)"$/) do |field, value|
  actual = @message.body[field]
  raise "expected message field #{field} to have value #{value} but was #{actual}" unless field.eql?(actual)
end

Then(/^the (?:response|message|sms|email) should have no errors$/) do
  raise "Found error: #{@message.errors.inspect}" unless @message.errors.nil?
end

Then(/^the response body should contain valid _links$/) do
  raise "self not found _links: #{email.response.body['_links']}".red unless @message.get.response.body['_links']['self'].include?('messages/email')
  raise "recipients not found _links:#{email.response.body['_links']}".red unless @message.get.response.body['_links']['recipients'].include?('recipients')
end

And(/^the response should contain a message_type_code with value '(.*)'$/) do |message_type_code|
  code = @message.get.response.body['message_type_code']
  raise "message type code field not found".red if code.nil?
  raise "message type code not found in #{code}".red unless code == message_type_code
end

And(/^the response should contain a link to the message type$/) do
  expect(@message.message_type).to be_a(GovDelivery::TMS::MessageType)
end

Then(/^the response should have only one recipient$/) do
  GovDelivery::Proctor.backoff_check(5.minutes, "should have only one recipient") do
  begin
    no_of_recipients = @message.get.recipients.get.collection
    log.info ("Collection of recipients: #{no_of_recipients}")
    no_of_recipients.length == 1
    rescue GovDelivery::TMS::Request::InProgress
    false
  end
  end
end

Then(/^the reply to address should be the from email address/) do
  email = @message.get
  raise "reply to address: #{email.reply_to} should equal from addres: #{email.from_email}" unless email.from_email.eql?(email.reply_to)
end

Then(/^the errors to address should default to the account level errors to email$/) do
  expected = configatron.tms.account.errors_to
  actual = @message.get.errors_to
  raise "Did not set proper errors_to address expected:#{expected} actual:#{actual}" unless expected == actual
end

Then(/^those params should resolve within the body of the email I send$/) do
  begin
    GovDelivery::Proctor.backoff_check(10.minutes, 'looking for link params in email body') do
      log.info("Checking Gmail IMAP for subject \"#{@subject}\"")
      emails = Mail.find(what: :last, count: 1000, order: :dsc)
      log.info("Found #{emails.size} emails")
      log.info("subjects:\n\t#{emails.map(&:subject).join("\n\t")}") if emails.any?

      if (message = emails.detect { |mail| mail.subject == @subject })
        doc = Nokogiri::HTML.parse(message.html_part.body.decoded) # Using Nokogiri to parse out the HTML to be something more readable
        url = doc.css('p a').map { |link| link['href'] }[0] # forcing an array mapping to the first <a href> within the first <p> tag since the email is built like that
        log.info("Link found goes to: #{url}".green)

        if url.include? 'utf8=true'
          log.info("params found in #{url}".green)
        else
          raise "params not found in #{url}".red
        end
      end
    end
  ensure
    Mail.find_and_delete(what: :all)
    log.info('Inbox email deleted'.green) if Mail.all == []
  end
end

Then(/^I should be able to list and read from addresses/) do
  raise "unable to any from_address: #{@addresses}" unless @addresses.collection
  raise "unable to get id from a from_address: #{@addresses}" unless @addresses.collection.first.id
end
