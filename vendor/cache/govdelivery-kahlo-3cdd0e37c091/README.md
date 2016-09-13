# GovDelivery::Kahlo

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/govdelivery/kahlo`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'govdelivery-kahlo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install govdelivery-kahlo

## Usage

### send a message

```ruby
    # If you're using govdelivery-synapse directly, 
    # you just need to configure that
    GovDelivery::Kahlo.configure do |kahlo|
        kahlo.kafkas = 'localhost:9092,localhost:9093'
        kahlo.source = 'xact'
    end
    
    client = GovDelivery::Kahlo::Client.new
    client.deliver_message {
        to: '+16514888888',
        from: '468311',
        callback_id: 'pizza',
        body: "havin' a 'roni"
    }

```

## receive status callbacks for your specified source 
 
 ```ruby
    
    
   client = GovDelivery::Kahlo::Client.new
   
   # this looks at the `sender_src` and returns only the ones that match your configured source
   # it'll register a listener, so use it 
   # with the govdelivery-synapse `synapse` executable and it'll Just Work:  
   klass = client.handle_status_callbacks do |msg|  
     Message.find(msg['callback_id']).update_attribute(:status, msg['status'])
     # or whatever
   end
 
 ```

## use to/from number validations

The gem includes some helper methods to perform basic sanity checks on to/from numbers. 
If you `require 'govdelivery/kahlo/validation_helper`, you can `include GovDelivery::Kahlo::ValidationHelper`
in your client code classes to do validations earlier on (e.g. in AR models).

It also includes the global_phone gem, so you have that at your disposal. It's what Kahlo uses 
internally for validations.

 
 
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/govdelivery-kahlo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

