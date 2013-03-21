#!/usr/bin/env ruby
require 'optparse'

class CreateAccount
  def run_from_options(argv)
    parse_options(argv)
    boot_rails

    create_account(@options)

  end

  def boot_rails
    require File.expand_path("../../config/environment", __FILE__)
  end
  
  def parse_options(argv)
    argv[0] = '--help' unless argv[0]
    @options = {}
    OptionParser.new do |opts|
      opts.banner = <<-USAGE
Usage: 
  #{__FILE__} [options]

Examples: 
  Create Account
    #{__FILE__} -n "INSURE SC Test Account" -t 10025 -d "TOR_TEST,FOO"
    
Options:
USAGE
      opts.on("-n", "--name Account Name") do |p|
        @options[:account_name] = p.to_s
      end
      opts.on("-v", "--voice_vendor Voice Vendor") do |p|
        @options[:account_voice_vendor] = p
      end
      opts.on("-t", "--sms_vendor Sms Vendor") do |p|
        @options[:account_sms_vendor] = p
      end
      opts.on("-e", "--email_vendor Email Vendor") do |p|
        @options[:account_email_vendor] = p
      end
      opts.on("-d", "--dcm_account_codes DCM Account Codes") do |p|
        @options[:dcm_account_codes] = p.split(/,/)
      end
    end.parse!(argv)
  end
    
  def out(str)
    puts(str) unless RAILS_ENV == 'test'
  end

  def create_account(options)

    a = Account.new
    a.name = @options[:account_name]
    a.voice_vendor_id = @options[:account_voice_vendor]
    a.sms_vendor_id = @options[:account_sms_vendor]
    a.email_vendor_id = @options[:account_email_vendor]
    a.dcm_account_codes = @options[:dcm_account_codes]

    a.save

    puts "Created Account id: " + a.id.to_s 

  end

end



if __FILE__ == $0
  CreateAccount.new.run_from_options(ARGV)
end

