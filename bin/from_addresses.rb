#!/usr/bin/env ruby
require 'optparse'
require 'csv'

class FromAddressManager
  def list(from_addresses)
    fields = [:id, :created_at, :from_email, :bounce_email, :reply_to_email, :from_name, :is_default]
    out fields.map { |f| f.to_s.ljust(25)}.join("\t\t")
    out '=' * 220
    from_addresses.map do |fa|
      out fields.map { |f| fa.send(f).to_s.ljust(30)}.join("\t\t")
    end
    out '=' * 220
  end

  def initialize(argv)
    options = parse_options(argv)
    require File.expand_path('../../config/environment', __FILE__)

    @account = if options[:account_id]
                Account.find(options[:account_id])
              else
                raise 'ERROR: No account id specified!'
              end

    case
    when options[:input]
      bulk_create(options[:input], options[:dup_replies], options[:dup_errors])
    when options[:list]
      list(@account.from_addresses.order('created_at desc'))
    when options[:delete]
      @account.from_addresses.destroy_all
    when options[:from_address]
      begin
        @account.from_addresses.create!(options[:from_address])
        out 'From address created.'
        list(@account.reload.from_addresses)
      rescue ActiveRecord::RecordInvalid => e
        out "An error occurred: #{e.record.errors.full_messages}"
      end
    end
  end

  def parse_options(argv)
    argv[0] = '--help' unless argv[0]
    @options = {}
    OptionParser.new do |opts|
      opts.banner = <<-USAGE
Usage:
  #{__FILE__} [options]

Examples:

  List all From Addresses for an account
    #{__FILE__} -l -a 10040

  Delete all From Addresses for an account
    #{__FILE__} -D -a 10040


  Create a new From Address
    #{__FILE__}  -a 10000 -f ben@thesubstars.com -e errors@thesubstars.com -n "Ben O" -p replies@thesubstars.com -d

Options:
      USAGE

      opts.on('-l', '--list', 'Lists from addresses for account.') do |p|
        @options[:list] = p
      end
      opts.on('-D', '--delete-all', 'Deletes all from addresses from the specified account') do |p|
        @options[:delete] = p
      end
      opts.on('-a', '--account-id ACCOUNTID', 'Specifies the account to be used.') do |p|
        @options[:account_id] = p.to_s
      end
      opts.on('-f', '--from-address FROMADDRESS', 'Specifies a from address to create') do |p|
        @options[:from_address] ||= {}
        @options[:from_address][:from_email] = p
      end
      opts.on('-e', '--errors-to ERRORSTO', 'Specifies an errors-to address to create (errors_to and bounce_email are aliases)') do |p|
        @options[:from_address] ||= {}
        @options[:from_address][:bounce_email] = p
      end
      opts.on('-p', '--reply-to REPLYTOEMAIL', 'Specifies a Reply-To address to create (reply_to and reply_to_email are aliases)') do |p|
        @options[:from_address] ||= {}
        @options[:from_address][:reply_to_email] = p
      end
      opts.on('-n', '--from-name FROMNAME', 'Specifies a From Name to create') do |p|
        @options[:from_address] ||= {}
        @options[:from_address][:from_name] = p
      end
      opts.on('-d', '--default', 'Sets this from address as the account default') do |_p|
        @options[:from_address] ||= {}
        @options[:from_address][:is_default] = true
      end
      opts.on('-i', '--input CSV', 'Specifies an input csv to create addresses, has the format: from_address, reply_to, errors_to, is_default') do |p|
        @options[:input] = p
      end
      opts.on('-r', '--dup-replies', 'Used in conjunction with the input flag, makes reply_to addresses the same as the from_address specified in the csv if none is specified in the csv') do |_p|
        @options[:dup_replies] = true
      end
      opts.on('-q', '--dup-errors', 'Used in conjunction with the input flag, makes errors_to addresses the same as the from_address specified in the csv if none is specified in the csv') do |_p|
        @options[:dup_errors] = true
      end
    end.parse!(argv)
    @options
  end

  def out(str)
    puts(str) unless Rails.env == 'test'
  end

  def bulk_create(input, dup_replies = false, dup_errors = false)
    from_addresses = CSV.read(input, { headers: true, converters: :integer, header_converters: :symbol, force_quotes: true })
    from_addresses.each do |from_address|
      fields = [:from_address, :reply_to, :errors_to, :is_default]
      record_info = Hash[*from_address.select{|k,v| fields.include? k}.flatten]
      record_info[:is_default] = (record_info[:is_default] == 1) ? true : false
      record_info[:reply_to] ||= record_info[:from_address] if dup_replies
      record_info[:errors_to] ||= record_info[:from_address] if dup_errors
      begin
        @account.from_addresses.create!(record_info)
        puts "Created record for #{record_info[:from_address]}."
      rescue ActiveRecord::RecordInvalid => e
        puts "Record creation for #{record_info[:from_address]} failed due to: #{e.message}"
      end
    end
  end
end

FromAddressManager.new(ARGV) if __FILE__.include?($PROGRAM_NAME)
