#!/usr/bin/env ruby
require_relative '../config/environment'
require 'thor'

class KeywordsCLI < Thor


  desc 'list ACCOUNT_NAME', 'list custom keywords for account'
  option :all, desc: 'list both custom and special'
  option :special, desc: 'list only special keywords'
  def list(account_name)
    account = get_account(account_name)
    q = case
      when options[:all]
      account.keywords
      when options[:special]
      account.keywords.special
    else
      account.keywords.custom
    end
    print_table q.all.collect { |k| [k.name, k.response_text] }
  end

  option :response_text
  desc 'create ACCOUNT_NAME KEYWORD_NAME', 'create new custom command'
  def create(account_name, keyword_name)
    account = get_account(account_name)
    keyword = account.keywords.build(name: keyword_name, response_text: options[:response_text])
    if keyword.save!
      say "successfully created #{keyword.name}", :green
    else
      say "errors: #{keyword.errors}", :red
    end
  end

  # example 'response_text CUKEAUTO_QC_AUTOMATED  Keywords::AccountDefault For CUKE HELP, visit www.govdelivery.com'
  desc 'response_text ACCOUNT_NAME KEYWORD_NAME *RESPONSE_TEXT',
  'anything after KEYWORD_NAME will be used as text'
  def response_text(account_name, keyword_name, *response_text_words)
    account = get_account(account_name)
    keyword = get_keyword(account, keyword_name)
    response_text = response_text_words.join(' ')
    if response_text.empty? and yes?('remove response_text? (y/n): ')
      say("not changed", :red)
    elsif keyword.update_attribute( :response_text, response_text )
      say "successfully updated keyword", :green
    else
      say "errors: #{keyword.errors}", :red
    end
  end


  desc 'commands ACCOUNT_NAME KEYWORD_NAME', 'list commands for a keyword on an account'
  def commands(account_name, keyword_name)
    account = get_account(account_name)
    keyword = get_keyword(account, keyword_name)
    keyword.commands.each do |command|
      puts command.name
    end
  end

  private
  def get_account account_name
    Account.where(name: account_name).first or raise Thor::Error.new("#{account_name} not found")
  end

  def get_keyword account, keyword_name
    account.keywords.where(name: keyword_name).first or raise Thor::Error.new("#{keyword_name} not found")
  end

end

KeywordsCLI.start
