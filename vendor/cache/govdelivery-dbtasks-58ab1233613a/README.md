# Govdelivery::Dbtasks

Manages database tasks (rake stuff, test runs) in an unbreakable Oracle user/role context.  The working schema owns an application's datbase objects and data, but it is not possible to connect using the working schema's credentials.

A migrator user is employed to run migration-type tasks (`db:migrate`, `db:reset`, etc.) that executes DDL in the working schema.

An operator user is employed to execute DML at application runtime in the working schema.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'govdelivery-dbtasks'
```

And then execute:

    $ bundle

## Running tests

Create spec/database.yml (see spec/database.yml.example) first.

```ruby
bundle exec rspec
```

## Terms
### schema
The schema (`schema` in the yml) owns the database objects and data for an application.  The `schema` in a FedRAMP world is what a typical rails environment will use as the `username`.

The schema is locked -- no connections with its credentials can be created.

### migrator
The migrator (`migration_username` in the yaml) is associated with roles that grant it create, drop and alter database objects for the application's schema.

Migrations and other rake tasks use the migrator for connections.

### operator
The operator (`username` in the yaml) is associated with roles that allow it CRUD and execute permissions for an application's database objects.

At runtime all application connections use the operator.

## Usage

This contains modifications to oracle_enhanced_adapter that enable connections to set the current schema for FedRAMP compliance.

In short, we need different DB users to run migrations (or other DDL) than we do to run the app. So this enables those
users to set their current schema to a common value.

'Non-standard' config keys include
* `migration_username`: the database user responsible for DML
* `schema`: the database user that owns the objects and data

```
vagrant_defaults: &vagrant_defaults
  adapter: oracle_enhanced
  database: dev-oracledev1.local.gdi:1521/xe
  password: abcd1234
  checkout_timeout: 15
  pool: 10
  migration_username: gd_code_deploy

development:
  <<: *vagrant_defaults
  username: xact_oper
  schema: xact

test:
  <<: *vagrant_defaults
  username: xact_ut_oper
  schema: xact_ut

# etc. etc.

```

This code depends on appropriate roles and packages existing in the instance. If you're not sure you have these in place,
talk to a DBA. If you omit these parameters, the adapter will assume the app and migration users are the same.

It also overrides Active Record tasks with what's in databases.rake:

* db:create:all is disabled
* db:drop:all is disabled
* db:create is disabled, just prints a warning that our VM already does what we need (or the schema should otherwise already be in place).
* db:drop drops all objects in the schema rather than dropping the whole DB (since we can't do that)

### Testing your application

This gem uses appraisal to run against various combinations of rails and oracle-enhanced.

You most install gems globally for appraisal to work (e.g. rvm gemsets are okay but vendor/bundle is not)

    bundle install
    appraisal install
    appraisal rspec

Things should work in ruby 1.9.3, jruby 1.7.x, and Ruby 2.2.x. Please update this if that isn't what our applications
are current using.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
