#!/usr/bin/env ruby
require_relative '../config/environment'
require 'thor'

class CreateCommand < Thor

  # bin/create_command.rb CUKEAUTO_QC_AUTOMATED default \
  #   --command_type forward \
  #   --url tomale.com \
  #   --http_method get \
  #   --from_param_name user \
  #   --sms_body_param_name req

  desc 'create_command ACCOUNT_NAME KEYWORD_NAME', 'find or create keyword, then create command on it; use "start", "stop", "help", or "default" for special keywords'
  #CommandParameters::PARAMS
  class_option :sms_body_param_name
  class_option :command_type
  class_option :url
  class_option :http_method
  class_option :from_param_name
  class_option :strip_keyword #, type: :boolean
  def create(account_name, keyword_name)
    account = get_account(account_name)
    params = CommandParameters.new(options)
    puts "creating command on #{account.name} #{keyword_name}"
    command = account.create_command!(keyword_name, command_type: options[:command_type], params: params)
    say "created command: #{command.inspect}"
  end

  desc 'update COMMAND_ID', 'set zero or more options to update specific command parameters'
  def update(command_id)
    command = get_command( command_id )
    command.params.merge!( CommandParameters.new(options) )
    command.command_type = options[:command_type] if options[:command_type]
    say "command parameters:"
    print_table( command.params.to_hash, indent: 4 )
    if command.save!
      say "Updated command: #{command.id}", :green
    end
  end

  desc 'delete COMMAND_ID', 'delete command with id: ID'
  def delete(command_id)
    command = get_command(command_id)
    if yes?("delete command: #{command.name} ? (y/n): " ) && command.destroy
      say "Successfully deleted command"
    end
  end

  desc 'list ACCOUNT_NAME KEYWORD_NAME', 'list commands'
  def list(account_name, keyword_name)
    account = get_account(account_name)
    keyword = get_keyword(account, keyword_name)
    commands = keyword.commands.collect do |command|
      say [command.id, command.name].join(' ')
      print_table command.params.to_hash, indent: 4
    end
  end

  desc 'list ACCOUNT_NAME KEYWORD_NAME', 'list latest command actions'
  option :phone, desc: 'can be partial string of a phone number'
  option :limit, default: 10, type: :numeric
  option :offset, default: 0, type: :numeric
  def actions(account_name, keyword_name)
    account = get_account(account_name)
    keyword = get_keyword(account, keyword_name)
    q = CommandAction.joins(:inbound_message).limit(options[:limit]).
      where("inbound_messages.keyword_id" => keyword.id).
      order('command_actions.created_at desc')
    if options[:phone]
      q = q.where("inbound_messages.caller_phone like ?", "%#{options[:phone]}%" )
    end
    if options[:offset]
      q = q.offset(options[:offset])
    end
    puts q.to_sql
    q.each do |action|
      say [action.id, action.created_at.utc].join(' '), :green
      attributes = action.attributes.slice('status', 'content_type', 'response_body')
      attributes['status'] = attributes['status'].to_s #number to string
      inbound_message_attributes = action.inbound_message.attributes.slice('caller_phone', 'body', 'command_status')
      print_table( attributes.merge(inbound_message_attributes), indent: 4)
    end
    say "sorry no results", :red if q.size.zero?
  end

  private

  def get_account account_name
    Account.where(name: account_name).first or raise Thor::Error.new("#{account_name} not found")
  end

  def get_keyword account, keyword_name
    account.keywords.where(name: keyword_name).first or raise Thor::Error.new("#{keyword_name} not found")
  end

  def get_command command_id
    ::Command.find(command_id) or raise Thor::Error.new("command: #{command_id} not found")
  end

end

CreateCommand.start
