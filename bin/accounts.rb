#!/usr/bin/env ruby
require 'optparse'

class CreateAccount
  def run_from_options(argv)
    parse_options(argv)
    boot_rails

    if(@options[:list])
      list_accounts
    elsif(@options[:update_account])
      update_account(@options)
    elsif(@options[:account_id])
      display_account(Account.find(@options[:account_id]))
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

  Show An Account
    #{__FILE__} -i 123

  Create Account with exclusive SMS vendor
    #{__FILE__} -n "INSURE SC Test Account" -t 10025 -d "TOR_TEST,FOO"

  Create Account with shared SMS vendor, using prefix INS
    #{__FILE__} -n "INSURE SC Test Account" -t 10025 -d "TOR_TEST,FOO" -x "INS"

  Create Account with Email vendor
    #{__FILE__} -n "Email Test Account" -e 10025 -f "test@evotest.govdelivery.com"

  Create Account with IPAWS vendor
    #{__FILE__} -n "IPAWS Test Account" -a 10026

  Update Account Link Tracking Parameters
    #{__FILE__} -U -i 123 -L "utf8=true"

Options:
USAGE
      opts.on("-l", "--list", "List Accounts") do |p|
        @options[:list] = p
      end
      opts.on("-i", "--account_id ID", "Database ID of account to display") do |p|
        @options[:account_id] = p
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
      opts.on("-a", "--ipaws_vendor IPAWSVENDOR", "The database id of the desired IPAWS vendor") do |p|
        @options[:account_ipaws_vendor] = p
      end
      opts.on("-f", "--from_address [FROMADDRESS]", "The default from address for this account; required if there is an email vendor.") do |p|
        @options[:account_from_address] = p
      end
      opts.on("-o", "--from_number [FROMNUMBER]", "The default from number for this account; required if there is a voice vendor.") do |p|
        @options[:account_from_number] = p
      end
      opts.on("-r", "--reply_to [REPLYTO]", "The default reply-to email address for this account.  Defaults to the default from address if not supplied.") do |p|
        @options[:account_reply_to] = p
      end
      opts.on("-z", "--errors_to [ERRORSTO]", "The default errors-to email address for this account.  Defaults to the default from address if not supplied.") do |p|
        @options[:account_errors_to] = p
      end
      opts.on("-L", "--link_tracking_parameters [TRACKINGPARAMS]", "Link tracking parameters that will be appended to links emailed via the account.  Defaults to nothing if not supplied.") do |p|
        @options[:account_link_tracking_parameters] = p
      end
      opts.on("-p", "--help_text [HELP_TEXT]", "Optional, defaults to sms vendor help text") do |p|
        @options[:help_text] = p
      end
      opts.on("-s", "--stop_text [STOP_TEXT]", "Optional, defaults to sms vendor stop text") do |p|
        @options[:stop_text] = p
      end
      opts.on("-S", "--start_text [START_TEXT]", "Optional, defaults to sms vendor start text") do |p|
        @options[:start_text] = p
      end
      opts.on("-D", "--default_text [DEFAULT_TEXT]", "Optional, defaults to sms vendor help text") do |p|
        @options[:default_text] = p
      end
      opts.on("-d", "--dcm_account_codes ACCOUNTCODES") do |p|
        @options[:dcm_account_codes] = p.split(/,/)
      end
      opts.on("-x", "--sms_prefix PREFIX", "Prefix for SMS commands (required if using a shared sms vendor)") do |p|
        @options[:sms_prefix] = p
      end
      opts.on("-U", "--update", "Update fields of an account. -i ACCOUNT_ID is required. Updateable fields are -n, -t, -p, -s, -S, and -D") do |p|
        @options[:update_account] = true
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
    a.ipaws_vendor_id = @options[:account_ipaws_vendor]
    a.dcm_account_codes = @options[:dcm_account_codes]
    # create an sms prefix if the sms vendor is shared
    if(@options[:sms_prefix] && SmsVendor.find(@options[:account_sms_vendor]).shared?)
      a.sms_prefixes.build(:prefix=>@options[:sms_prefix])
    end

    if(@options[:account_from_address])
      a.from_addresses.build({
        :from_email   => @options[:account_from_address],
        :reply_to     => @options[:account_reply_to],
        :errors_to    => @options[:account_errors_to],
        :is_default   => true
      })
    end

    if(@options[:account_link_tracking_parameters])
      a.link_tracking_parameters = @options[:account_link_tracking_parameters]
    end

    if (@options[:account_from_number])
      a.from_numbers.build({
         phone_number: @options[:account_from_number],
         is_default: true
        })
    end

    a.save

    if(!a.errors.empty?)
      puts a.errors.messages
    else
      set_sms_texts(a, options)
      puts "Created Account id: " + a.id.to_s
      display_account(a)
    end

  end

  def update_account(options)
    if not @options[:account_id]
      puts "Error: Must provide account ID to update via -i/--account_id"
      return
    end

    a = Account.find(@options[:account_id])

    options_to_fields = {
      account_name: :name,
      account_link_tracking_parameters: :link_tracking_parameters
    }

    updates = {}

    options_to_fields.each do |k, v|
      if options.include?(k)
        updates[v] = options[k]
      end
    end

    a.update(updates)

    if (!a.errors.empty?)
      puts a.errors.messages
    else
      set_sms_texts(a, options)
      puts "Updated Account id: " + a.id.to_s
      display_account(a)
    end
  end

  def list_accounts
    Account.all.each do |a|
      display_account(a)
    end
  end

  def display_account(account)
    puts "#{account.name}", "-" * 60

    tputs "id:", account.id.to_s
    tputs "name:", account.name
    tputs "sms vendor:", account.sms_vendor_id.to_s
    tputs "voice vendor:", account.voice_vendor_id.to_s
    tputs "email vendor:", account.email_vendor_id.to_s
    tputs "ipaws vendor:", account.ipaws_vendor_id.to_s
    ['default', 'help', 'stop', 'start'].each do |type|
      tputs "#{type} text:", account.send(:"#{type}_keyword").response_text if account.send(:"#{type}_keyword").try(:response_text)
    end
    if(account.email_vendor_id)
      tputs "default from email:", account.default_from_address.from_email.to_s
      tputs "default reply-to:", account.default_from_address.reply_to.to_s
      tputs "default errors-to:", account.default_from_address.errors_to.to_s
      tputs "link_tracking_parameters:", account.link_tracking_parameters.to_s
    end
    account.sms_prefixes.each do |p|
      tputs "sms prefix:", p.prefix
    end
    tputs "dcm accounts:", account.dcm_account_codes.to_a.join(",")
    puts ""
  end

  def tputs(key,value)
    puts "\t#{key.ljust(30)}#{value}"
    end

  def set_sms_texts(account, options)
    ['default', 'help', 'stop', 'start'].each do |type|
      next unless options[:"#{type}_text"]
      keyword = account.send(:"#{type}_keyword")
      keyword.response_text = options[:"#{type}_text"]
      keyword.save
    end
  end
end

if __FILE__ == $0
  CreateAccount.new.run_from_options(ARGV)
end

