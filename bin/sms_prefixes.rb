#!/usr/bin/env ruby
require_relative '../config/environment'
require 'thor'

class SmsPrefixesCLI < Thor


  desc 'list', 'show all sms prefixes'
  option :account_name, aliases: ["-a"], desc: 'the NAME of the account, show only sms_prefixes for an account'
  option :sms_vendor_name, aliases: ["-v"], desc: 'the NAME of the vendor, show only sms_prefixes for a sms vendor'
  def list
    q = SmsPrefix.select('*') #dummy query
    if options[:account_name] && (account = get_account( options[:account_name] ))
      q = q.where(account_id: account.id)
    end
    if options[:sms_vendor_name] && (sms_vendor = get_sms_vendor(options[:sms_vendor_name]))
      q = q.where(sms_vendor_id: sms_vendor.id)
    end
    headers = [['ID', 'PREFIX', 'ACCOUNT NAME', 'SMS VENDOR NAME']]
    print_table( headers + q.collect {|sms_prefix| [sms_prefix.id, sms_prefix.prefix, sms_prefix.account.try(:name), sms_prefix.sms_vendor.try(:name)] })
  end

  desc 'delete SMS_PREFIX ID', 'destroy an sms prefix'
  def delete(id)
    if (sms_prefix = SmsPrefix.find(id.to_i)) && yes?("Delete #{sms_prefix.prefix}? (y/n): ") && sms_prefix.destroy
      say "successfully deleted SmsPrefix: #{id}", :green
    else
      say "deletion aborted", :red
    end
  end

  desc 'create PREFIX -a ACCOUNT_NAME', 'create sms prefix for account'
  option :account_name, aliases: ["-a"], required: true, desc: 'the NAME of the account'
  def create(prefix)
    account = get_account(options[:account_name])
    sms_prefix = account.sms_prefixes.build prefix: prefix
    if sms_prefix.save
      say "successfully created SmsPrefix: #{prefix}", :green
    else
      say "errors creating SmsPrefix: #{sms_prefix.errors}", :red
    end
  end

  desc 'update -i 789 -p NEW_PREFIX', 'change prefix value on sms_prefix'
  option :prefix, aliases: ['-p'], desc: 'the value of the prefix', required: true
  option :id, aliases: ['-i'], required: true, desc: 'the id of the sms_prefix', type: :numeric
  def update
    sms_prefix = SmsPrefix.find(options[:id])
    if sms_prefix.update_attribute( :prefix, options[:prefix] )
      say "successfully created SmsPrefix: #{options[:prefix]}", :green
    else
      say "errors creating SmsPrefix: #{sms_prefix.errors}", :red
    end
  end


  private
  def get_account account_name
    Account.where(name: account_name).first or raise Thor::Error.new("#{account_name} not found")
  end

  def get_sms_vendor sms_vendor_name
    SmsVendor.where(name: sms_vendor_name).first or raise Thor::Error.new("#{sms_vendor_name} not found")
  end
end

SmsPrefixesCLI.start
