#!/usr/bin/env ruby
require 'optparse'
require 'bundler'
Bundler.setup
require 'pry'
class StopHandlers
  def run_from_options(argv)
    parse_options(argv)
    boot_rails
    
    if(@options[:account_id])
      if(@options[:list])
        list_stop_handlers(@options[:account_id])
      elsif(@options[:create])
        create_stop_handler(@options[:account_id], @options[:create])
      elsif(@options[:delete])
        delete_stop_handler(@options[:account_id], @options[:delete])
      end
    end

  end

  def boot_rails
    require File.expand_path("../../config/environment", __FILE__)
  end

  def list_stop_handlers(account_id)
    puts
    a  = Account.find(account_id)
    sh = a.stop_handler
    puts "Account: #{a.name}"
    puts "Sms Vendor: #{a.sms_vendor.try(:name)} (#{a.sms_vendor_id})"
    puts "Stop Handler: #{sh.id}"
    sh.commands.each do |command|
      puts "-" * 30
      puts "\tCommand: #{command.id}"
      puts "\tName: #{command.name}"
      print "\tParams: " 
      puts(command.params.to_hash.to_json)
    end
    puts
  end

  def create_stop_handler(account_id, params)
    params = JSON.parse(params)
    account = Account.find(account_id)
    account.add_command!(params)
    puts "Created!"
    list_stop_handlers(account_id)
  end

  def delete_stop_handler(account_id, command_id)
    command = Command.find_by_id_and_account_id(command_id, account_id) || raise("Can't find command with id #{command_id} and account id #{account_id}")
    command.destroy
    puts "Deleted #{command}"
    list_stop_handlers(account_id)
  end

  def parse_options(argv)
    argv[0] = '--help' unless argv[0]
    @options = {}
    OptionParser.new do |opts|
      opts.banner = <<-USAGE
Usage: 
  #{__FILE__} [options]

Examples: 

  List Stop Handlers for account
    #{__FILE__} --account ID --list
      
  Create Stop Handler 
    #{__FILE__} --account ID --create '{"params": {"dcm_account_codes":["DEF456","CUKEAUTO_QC"]}, "command_type": "dcm_unsubscribe"}'

  Delete a Stop Handler
    #{__FILE__} --account ID --delete 10324
Options:
USAGE
      opts.on("-l", "--list", "List Stop Handlers") do |p|
        @options[:list] = true
      end

      opts.on("-a", "--account ID", "Account ID") do |id|
        @options[:account_id] = id
      end

      opts.on("-c", "--create PARAMS", "Create a stop handler with given parameters") do |p|
        @options[:create] = p
      end

      opts.on("-d", "--delete COMMAND_ID", "Delete a stop handler with given command id") do |p|
        @options[:delete] = p
      end
    end.parse!(argv)
  end
end

if __FILE__ == $0
  StopHandlers.new.run_from_options(ARGV)
end