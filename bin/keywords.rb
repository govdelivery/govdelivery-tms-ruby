#!/usr/bin/env ruby
require_relative '../config/environment'
require 'thor'
require 'csv'
class KeywordsCLI < Thor


  default_task :list

  desc 'list ACCOUNT_NAME', 'list custom keywords for account'
  option :all, desc: 'list both custom and special'
  option :special, desc: 'list only special keywords'
  def list(account_name=nil)
    account = get_account(account_name) if account_name
    q = case
        when account.nil?
          Keyword.custom.limit(100)
        when options[:all]
          account.keywords
        when options[:special]
          account.keywords.special
        else
          account.keywords.custom
        end
    print_table q.all.collect { |k| [k.id, k.name, k.response_text] }
  end

  desc 'create ACCOUNT_NAME KEYWORD_NAME', 'create new custom command'
  option :response_text, aliases: ["-r"], desc: "text sent to the user when this keyword is detected"
  def create(account_name, keyword_name)
    account = get_account(account_name)
    keyword = account.keywords.build(name: keyword_name, response_text: options[:response_text])
    if keyword.save!
      say "successfully created #{keyword.name}", :green
    else
      say "errors: #{keyword.errors}", :red
    end
  end

  # example 'response_text CUKEAUTO_QC_AUTOMATED  default For CUKE HELP, visit www.govdelivery.com'
  desc 'set_response_text ACCOUNT_NAME KEYWORD_NAME *RESPONSE_TEXT',
  'anything after KEYWORD_NAME will be used as text'
  def set_response_text(account_name, keyword_name, *response_text_words)
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

  desc 'delete KEYWORD_ID', 'destroy keyword'
  def delete(keyword_id)
    if (keyword = Keyword.find(keyword_id.to_i)) && yes?("Delete #{keyword.name}? (y/n): ") && keyword.destroy
      say "successfully deleted Keyword: #{keyword_id}", :green
    else
      say "deletion aborted", :red
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

  desc 'bulk_create ACCOUNT_NAME FILE', "create many keywords at once using a keyword CSV file. The file format is:\n'KEYWORD_NAME','RESPONSE TEXT'"
  def bulk_create(account_name, file)
    account = get_account(account_name)
    if !File.readable?(file)
      raise Thor::Error.new("can't read #{file}")
    end
    CSV.foreach(file) do |l|
      keyword_name, response_text = l[0..1]
      keyword = account.keywords.build(name: keyword_name, response_text: response_text)
      if keyword.save
        say "successfully created #{keyword.name}", :green
      else
        say "errors creating #{keyword.name}: #{keyword.errors.full_messages.to_sentence}", :red
      end
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
