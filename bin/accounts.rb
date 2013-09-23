#!/usr/bin/env ruby
require 'optparse'

class CreateAccount
  def run_from_options(argv)
    parse_options(argv)
    boot_rails
    
    if(@options[:list])
      list_accounts
    else
      create_account(@options)
    end

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

  List All Accounts
    #{__FILE__} -l

  Create Account with exclusive SMS vendor
    #{__FILE__} -n "INSURE SC Test Account" -t 10025 -d "TOR_TEST,FOO"

  Create Account with shared SMS vendor, using prefix INS
    #{__FILE__} -n "INSURE SC Test Account" -t 10025 -d "TOR_TEST,FOO" -x "INS"

  Create Account with Email vendor
    #{__FILE__} -n "Email Test Account" -e 10025 -f "test@evotest.govdelivery.com"
    
Options:
USAGE
      opts.on("-l", "--list", "List Accounts") do |p|
        @options[:list] = p
      end
      opts.on("-n", "--name ACCOUNTNAME") do |p|
        @options[:account_name] = p.to_s
      end
      opts.on("-v", "--voice_vendor VOICEVENDOR", "The database id of the desired voice vendor") do |p|
        @options[:account_voice_vendor] = p
      end
      opts.on("-t", "--sms_vendor SMSVENDOR", "The database id of the desired sms vendor") do |p|
        @options[:account_sms_vendor] = p
      end
      opts.on("-e", "--email_vendor EMAILVENDOR", "The database id of the desired email vendor") do |p|
        @options[:account_email_vendor] = p
      end
      opts.on("-f", "--from_address [FROMADDRESS]") do |p|
        @options[:account_from_address] = p
      end
      opts.on("-p", "--help_text [HELP_TEXT]", "Optional, defaults to sms vendor help text") do |p|
        @options[:help_text] = p
      end
      opts.on("-s", "--stop_text [STOP_TEXT]", "Optional, defaults to sms vendor stop text") do |p|
        @options[:stop_text] = p
      end
      opts.on("-d", "--dcm_account_codes ACCOUNTCODES") do |p|
        @options[:dcm_account_codes] = p.split(/,/)
      end
      opts.on("-x", "--sms_prefix PREFIX", "Prefix for SMS commands (required if using a shared sms vendor)") do |p|
        @options[:sms_prefix] = p
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
    a.help_text = @options[:help_text]
    a.stop_text = @options[:stop_text]
    # create an sms prefix if the sms vendor is shared
    if(@options[:sms_prefix] && SmsVendor.find(@options[:account_sms_vendor]).shared?)
      a.sms_prefixes.build(:prefix=>@options[:sms_prefix])
    end

    if(@options[:account_from_address])
      # this only sets the from_email, which is the default for the other values if they are not present
      f = FromAddress.new
      f.from_email = @options[:account_from_address]
      a.from_address = f
      a.save
    else
      a.save
    end

    if(a.errors)
      puts a.errors.messages
    else
      puts "Created Account id: " + a.id.to_s 
    end

  end

  def list_accounts

    puts "Account.all\n";
    Account.all.each { |a|
      puts "\tid: " + a.id.to_s + "\n"
      puts "\tname: " + a.name + "\n"
      puts "\tsms vendor: " + a.sms_vendor_id.to_s + "\n"
      puts "\tvoice vendor: " + a.voice_vendor_id.to_s + "\n"
      puts "\temail vendor: " + a.email_vendor_id.to_s + "\n"
      if(a.help_text)
        puts "\thelp text: " + a.help_text + "\n"
      end
      if(a.stop_text)
        puts "\tstop text: " + a.stop_text + "\n"
      end
      if(a.email_vendor_id) 
        puts "\tfrom email: " + a.from_address.from_email.to_s + "\n" 
      end
      a.sms_prefixes.each do |p|
        puts "\tsms prefix: " + p.prefix + "\n"
      end
      print "\tdcm accounts: " 
      a.dcm_account_codes.each { |d| print d + "," }
      puts "\n\n"
    }

  end

end



if __FILE__ == $0
  CreateAccount.new.run_from_options(ARGV)
end

