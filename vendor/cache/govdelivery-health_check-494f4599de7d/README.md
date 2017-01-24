# GovDelivery::HealthCheck

GovDelivery::HealthCheck::Web is a Rack app that offers some information about an app's health.

Features:
* checks AR, redis, sidekiq
* checks to see if system is about to shut down or is down for maintenance

This is arguably an improvement over managing F5s on a per-node basis since it lets you put logic
about node health in the load balancers rather than service scripts; just return a 307 and the LB
knows not to send you any more requests until you return an all-clear 200.

| status | what it means                | how you do it                                |
| ------ | ---------------------------- | ---------------------------------------------|
|  200   | app is up everything is cool | have everything work                         |
|  202   | app is potentially in a degraded state  | check calls warn!                 |
|  500   | health check failed          | check raises an exception                    |
|  503   | app is down for maintenance  | touch /var/run/maintenance.lock              |
|  518   | health check failed          | check raises a known exception through fail! |

The files to check can be overridden when mounting the app, see RDocs for details.

You'll need your service scripts to support this as well, of course.

TODO:
* auto-disable irrelevant checks on init rather than checking for presence of ActiveRecord etc. every time
* make file checks like other checks (i.e. in their own singleton class)
* create a library of non-default checks: kafka, zk, external services, etc.
* check Kafka/schema registry connections
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
```

### Add your own check

```ruby

class MyCustomCheck < GovDelivery::HealthCheck::Checks::Base
  def check!
    warn!('Thursday performance degradation') if Date::ABBR_DAYNAMES[Date.today.wday] == 'Thu'
    fatal!('app is broken on Saturdays') if Date::ABBR_DAYNAMES[Date.today.wday] == 'Sat'
    # otherwise just return if everything is okay
  end
end

# routes

health_check = GovDelivery::HealthCheck::Web.new
health_check.checks << MyCustomCheck # or GovDelivery::HealthCheck::Web.checks << MyCustomCheck to make this check run for every instance

# ... then mount as above

end

```

See the code for default values, change them if you have special requirements
(e.g. two services running on one machine).

## Custom checks

Implement a class that inherits from `GovDelivery::HealthCheck::Checks::Base` and implements the `check!` method. In `check!` call one of the following:

- `pass!` (`noop!`): The check passed, no issue
- `warn!`:         The check failed, but won't cause the node to be marked as erroring. This is useful predominantly for checking background services that don't necessarily indicate web-node health.
- `fatal!`:        The check failed, return a node error so that the web node can be marked down

If none of these are called and execution succeeds the check is **automatically considered a pass**.

If an exception is thrown and unhandled during execution of the check the check is considered an error. The check states correspond to the following http statuses:

- pass/noop: 200
- warn: 202
- fatal: 518
- error: 500

**Fatal v. Error**: the difference between these two statuses is where you have a known error where you want to return more customized information regarding the error. If the error is known, call `fail!` otherwise, if an unhandled exception occurs it will be rescued and the exception message will be shown along with the 500 error response.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
