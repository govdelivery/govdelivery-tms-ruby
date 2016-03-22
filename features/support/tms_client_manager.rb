require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'awesome_print'
require 'colored'
require 'mail'
require 'pry'

module TmsClientManager

  def from_configatron(conf)
    GovDelivery::TMS::Client.new(conf.xact.user.token, api_root: conf.xact.url)
  end

  def admin_client
    @admin_client ||= GovDelivery::TMS::Client.new(configatron.tms.admin.token, api_root: configatron.tms.api_root)
  end

  def non_admin_client
    @non_admin_client ||= GovDelivery::TMS::Client.new(configatron.tms.non_admin.token, api_root: configatron.tms.api_root)
  end

  def non_admin_token
    configatron.tms.non_admin.token
  end

  def url
    configatron.tms.url
  end

  def from_email
    configatron.tms.from_email
  end

  def account_code
    configatron.tms.account_code
  end

  def mail_accounts
    configatron.tms.mail_accounts
  end

  def password
    configatron.tms.password
  end

  def topic_code
    configatron.tms.topic_code
  end

  def subject
    configatron.tms.default_subject
  end

  extend self
end
