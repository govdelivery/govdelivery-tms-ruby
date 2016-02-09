[![Build Status](https://travis-ci.org/govdelivery/govdelivery-tms-ruby.svg?branch=master)](https://travis-ci.org/govdelivery/govdelivery-tms-ruby)

TMS Client
===========
This is a reference Ruby client to interact with the GovDelivery TMS REST API.

Installation
------------
### Using Bundler

```ruby
gem 'govdelivery-tms'
```

### Standalone

```
$ gem install govdelivery-tms
```


Connecting
----------
Loading an instance of `GovDelivery::TMS::Client` will automatically connect to the API to query the available resources for your account.

```ruby
# default api root endpoint is https://tms.govdelivery.com
client = GovDelivery::TMS::Client.new('auth_token', :api_root => 'https://stage-tms.govdelivery.com')
```

Messages
--------

### Loading messages
Sms and Email messages can be retrieved with the `get` collection method.  Messages are paged in groups of 50.  To retrieve another page, used the `next` method.  This method will not be defined if another page is not available.

```ruby
client.sms_messages.get        # get the first page of sms messages
client.sms_messages.next.get   # get the next page of sms messages
```


### Sending an SMS Message

```ruby
message = client.sms_messages.build(:body=>'Test Message!')
message.recipients.build(:phone=>'5551112222')
message.recipients.build(:phone=>'5551112223')
message.recipients.build # invalid - no phone
message.post             # true
message.recipients.collection.detect{|r| r.errors } # {"phone"=>["is not a number"]}
# save succeeded, but we have one bad recipient
message.href             # "/messages/sms/87"
message.get              # <GovDelivery::TMS::SmsMessage href=/messages/sms/87 attributes={...}>
```

### Retrieving Inbound SMS Messages
```ruby
client.inbound_sms_messages.get                             # <GovDelivery::TMS::InboundSmsMessages href=/inbound/sms attributes={...}>
inbound_sms = client.inbound_sms_messages.collection.first  # <GovDelivery::TMS::InboundSmsMessage href=/inbound/sms/10041 attributes={...}>
inbound_sms.to                                              # "+15559999999"
inbound_sms.from                                            # "+15005550006"
inbound_sms.attributes                                      # {:from=>"+15005550006", :to=>"+15559999999", :body=>"test", :command_status=>"success", :keyword_response=>"kwidjebo", :created_at=>"2014-11-05T17:15:01Z"}

```

### Sending an Email Message

```ruby
message = client.email_messages.build(:body=>'<p><a href="http://example.com">Visit here</a></p>',
                                      :subject => 'Hey',
                                      :from_email => 'foo@example.com')
message.recipients.build(:email=>'example1@example.com')
message.recipients.build(:email=>'')
message.post             # true
message.recipients.collection.detect{|r| r.errors } # {"email"=>["can't be blank"]}
# save succeeded, but we have one bad recipient
message.href             # "/messages/email/87"
message.get              # <GovDelivery::TMS::EmailMessage href=/messages/email/88 attributes={...}>
```

#### Sending an Email with Macros

```ruby
message = client.email_messages.build(:subject=>'Hello!',
                                      :body=>'<p>Hi <span style="color:red;">[[name]]</span>!</p>',
                                      :macros=>{"name"=>"there"})
message.recipients.build(:email=>'jim@example.com', :macros=>{"name"=>"Jim"})
message.recipients.build(:email=>'amy@example.com', :macros=>{"name"=>"Amy"})
message.recipients.build(:email=>'bill@example.com')
message.post
```

### Creating an Email Template

```ruby
template = client.email_templates.build(subject: 'A templated subject',
                                        body: 'Hi [[name]], this body is from a template.',
                                        macros: {"name"=>"person"})
template.post
```

### Sending an Email using a Template

Assuming you created `template` above:

```ruby
message = client.email_messages.build
message.links[:email_template] = template.id
message.recipients.build(:email=>'jim@example.com', :macros=>{"name"=>"Jim"})
message.recipients.build(:email=>'amy@example.com', :macros=>{"name"=>"Amy"})
message.recipients.build(:email=>'bill@example.com')
message.post
```

Webhooks
-------
### POST to a URL when a recipient is blacklisted (i.e. to remove from your list)  


```ruby
webhook = client.webhooks.build(:url=>'http://your.url', :event_type=>'blacklisted')
webhook.post # true
```

POSTs will include in the body the following attributes:

  attribute   |  description
------------- | -------------
message_type  | 'sms' or 'email'
status:       |  message state
recipient_url |  recipient URL
messsage_url  |  message URL
error_message |  (failures only)
completed_at  |  (sent or failed recipients only)


Metrics
-------
### Viewing recipients that clicked on a link in an email

```ruby
email_message.get
email_message.clicked.get
email_message.clicked.collection # => [<#EmailRecipient>,...]
```

### Viewing recipients that opened an email

```ruby
email_message.get
email_message.opened.get
email_message.opened.collection # => [<#EmailRecipient>,...]
```

### Viewing a list of statistics for a recipient

```ruby
email_recipient.clicks.get.collection #=> [<#EmailRecipientClick>,...]

email_recipient.opens.get.collection #=> [<#EmailRecipientOpen>,...]
```

Configuring 2-way SMS
---------------------

### Listing Command Types
Command Types are the available commands that can be used to respond to an incoming SMS message.  

```ruby
command_types = client.command_types.get
command_types.collection.each do |at|
  puts at.name          # "forward"
  puts at.string_fields # ["url", ...]
  puts at.array_fields  # ["foo", ...]
end
```

### Managing Keywords
Keywords are chunks of text that are used to match an incoming SMS message.

```ruby
# CRUD
keyword = client.keywords.build(:name => "BUSRIDE", :response_text => "Visit example.com/rides for more info")
keyword.post                # true
keyword.name                # 'busride'
keyword.name = "TRAINRIDE"
keyword.put                 # true
keyword.name                # 'trainride'
keyword.delete              # true

# list
keywords = client.keywords.get
keywords.collection.each do |k|
  puts k.name, k.response_text
end
```

### Managing Commands
Commands have a command type and one or more keywords.  The example below configures the system to respond to an incoming SMS message containing the string "RIDE" (or "ride") by forwarding an http POST to `http://example.com/new_url`.  The POST body variables are documented in GovDelivery's [TMS REST API documentation](https://govdelivery.atlassian.net/wiki/display/PM/TMS+Customer+API+Documentation#TMSCustomerAPIDocumentation-Configuring2-waySMS "GovDelivery TMS REST API").

```ruby
# CRUD
keyword = client.keywords.build(:name => "RIDE")
keyword.post
command = keyword.commands.build(
            :name => "Forward to somewhere else",
            :params => {:url => "http://example.com", :http_method => "get"},
            :command_type => :forward)
command.post
command.params = {:url => "http://example.com/new_url", :http_method => "post"}
command.put
command.delete

# list
commands = keyword.commands.get
commands.collection.each do |c|
  puts c.inspect
end
```

### Viewing Command Actions
Each time a given command is executed, a command action is created.

**Note** The actions relationship does not exist on commands that have 0 command actions. Because of this, an attempt to access the command_actions attribute of a
command that has 0 command actions will result in a NoMethodError.

```ruby
# Using the command from above
begin
  command.get
  command_actions = command.command_actions
  command_actions.get
  command_action = command_actions.collection.first
  command_action.inbound_sms_message		# InboundSmsMessage object that initiated this command execution
  command_action.response_body			# String returned by the forwarded to URL
  command_action.status				# HTTP Status returned by the forwarded to URL
  command_action.content_type			# Content-Type header returned by the forwarded to URL
rescue NoMethodError => e
  # No command actions to view
end
```

Logging
-------

Any instance of a [Logger](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/logger/rdoc/Logger.html "Ruby Logger")-like class can be passed in to the client; incoming and outgoing request information will then be logged to that instance.

The example below configures `GovDelivery::TMS::Client` to log to `STDOUT`:

```ruby
logger = Logger.new(STDOUT)
client = GovDelivery::TMS::Client.new('auth_token', :logger => logger)
```

ActionMailer integration
------------------------

You can use TMS from the mail gem or ActionMailer as a delivery method.

Gemfile
```ruby
gem 'govdelivery-tms', :require=>'govdelivery/tms/mail/delivery_method'
```

config/environment.rb
```ruby
config.action_mailer.delivery_method = :govdelivery_tms
config.action_mailer.govdelivery_tms_settings = {
    :auth_token=>'auth_token',
    :api_root=>'https://tms.govdelivery.com'
    }
```


Generating Documentation
------------------------
This project uses [yard](https://github.com/lsegal/yard) to generate documentation.  To generate API documentation yourself, use the following series of commands from the project root:

```ruby
# install development gems
bundle install
# generate documentation
rake yard
```
The generated documentation will be placed in the `doc` folder.


Running Tests
-------------
```ruby
appraisal install
# optionally specify an activesupport version to test against (2/3/4), e.g.
# appraisal 4 rake          ## for ruby 2.1.2
appraisal rake
```


Compatibility
-------------
This project is tested and compatible with MRI 1.9.3, JRuby 1.7.12, and MRI 2.1.2.
