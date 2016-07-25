# GovDelivery::HealthCheck

GovDelivery::HealthCheck::Web is a Rack app that offers some information about an app's health.

Features:
* checks AR, redis, sidekiq
* checks to see if system is about to shut down or is down for maintenance

This is arguably an improvement over managing F5s on a per-node basis since it lets you put logic 
about node health in the load balancers rather than service scripts; just return a 307 and the LB
knows not to send you any more requests until you return an all-clear 200.

| status | what it means                | how you do it                        |
| ------ | ---------------------------- | -------------------------------------|
|  200   | app is up everything is cool | have everything work                 |
|  307   | app is shutting down         | touch /var/run/stop-service.lock     |
|  429   | app is potentially in a degraded state  | check raises a Warning    |
|  500   | health check failed          | check raises any non-Warning error  |
|  503   | app is down for maintenance  | touch /var/run/maintenance.lock      |

The files to check can be overridden when mounting the app, see RDocs for details.

You'll need your service scripts to support this as well, of course.

TODO:
* check Kafka/schema registry connections
* auto-disable irrelevant checks rather than checking for presence of ActiveRecord etc. 
* external services (IPAWS, Twitter, etc.)
* trap signals instead of checking for files (might not work for all servers)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'govdelivery-health_check'
```

## Usage

It's a Rack app, so there are lots of ways to mount it. Here are a few examples

```ruby
# rails config/routes.rb
mount GovDelivery::HealthCheck::Web.new(happy_text: '???????'), at: '/load_balancer'

# rackup config.ru
run Rack::URLMap.new(
  '/' => YourApp.new,            # or whatever
  '/sidekiq' => Sidekiq::Web,    # i don't care, really
  '/load_balancer' => GovDelivery::HealthCheck::Web.new(happy_text: 'how will i know if he really loves me')
  # ^^^^ that's the stuff  
)

### Add your own check

```ruby

class MyCustomCheck
  include Singleton  # needs to response to .instance
   
  def check!
    if Date::ABBR_DAYNAMES[Date.today.wday] == 'Thu'
        raise GovDelivery::HealthCheck::Warning.new('Thursday performance degradation')
    elsif Date::ABBR_DAYNAMES[Date.today.wday] == 'Sat'
        raise 'app is closed on Saturdays'
    end
    # otherwise just return if everything is okay
  end
end

# routes

health_check = GovDelivery::HealthCheck::Web.new
health_check.checks << MyCustomCheck

# ... then mount as above

end

```

See the code for default values, change them if you have special requirements 
(e.g. two services running on one machine).


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/govdelivery-health_check. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

