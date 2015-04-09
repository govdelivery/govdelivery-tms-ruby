#!/usr/bin/env ruby
require 'securerandom'
require 'optparse'

class CreateServiceUser
  def run_from_options(argv)
    parse_options(argv)
    boot_rails

    user = create_service_user(@options)
    display_user(user)
  end

  def boot_rails
    require File.expand_path('../../config/environment', __FILE__)
  end

  def parse_options(argv)
    argv[0] = '--help' unless argv[0]
    @options = {}
    OptionParser.new do |opts|
      opts.banner = <<-USAGE
Usage:
  #{__FILE__} [options]

Examples:

  Create Service User
    #{__FILE__} --sid "TWILIO_SID" --token "TWILIO_TOKEN" --phone "TWILIO_PHONE" --name "SERVICE_NAME" --email "SERVICE_EMAIL"

Options:
USAGE
      opts.on('-s', '--sid Twilio SID') do |p|
        @options[:sid] = p.to_s
      end
      opts.on('-t', '--token Twilio Token') do |p|
        @options[:token] = p.to_s
      end
      opts.on('-p', '--phone Phone') do |p|
        @options[:phone] = p.to_s
      end
      opts.on('-n', '--name Name') do |p|
        @options[:name] = p
      end
      opts.on('-e', '--email Email (username)') do |p|
        @options[:email] = p.to_s
      end
    end.parse!(argv)
    raise OptionParser::MissingArgument if @options[:sid].nil? || @options[:token].nil? || @options[:phone].nil? || @options[:name].nil? || @options[:email].nil?
  end

  def create_service_user(options)
    voice_vendor = VoiceVendor.create!(name: options[:name], username: options[:sid], password: options[:token], from: options[:phone], worker: 'TwilioVoiceWorker')
    sms_vendor = SmsVendor.create!(name: options[:name], username: options[:sid], password: options[:token], from: options[:phone], worker: 'TwilioMessageWorker')
    account = Account.create!(voice_vendor: voice_vendor, sms_vendor: sms_vendor, name: options[:name])
    user = User.new(email: options[:email], password: SecureRandom.hex, admin: false)
    user.account = account
    user.save!
    user
  end

  def display_user(u)
    puts "\tid: " + u.id.to_s + "\n"
    puts "\temail: " + u.email + "\n"
    puts "\taccount_id: " + u.account_id.to_s + "\n"
    puts "\tauth token: " + (u.authentication_tokens.first.try(:token) || '(n/a)') + "\n"
    puts "\n"
  end
end

CreateServiceUser.new.run_from_options(ARGV) if __FILE__ == $PROGRAM_NAME
