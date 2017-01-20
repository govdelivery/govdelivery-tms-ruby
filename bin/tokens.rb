#!/usr/bin/env ruby
require 'optparse'

class Tokens
  attr_accessor :options, :out

  def run_from_options(argv)
    parse_options(argv)
    boot_rails

    if @options[:list]
      list_tokens
    elsif @options[:listall]
      list_all_tokens
    elsif @options[:create]
      create_token
    elsif @options[:delete]
      delete_token
    else
      raise 'You need to specify either --create, --list, --list-all, or --delete'
    end
  end

  def boot_rails
    require File.expand_path('../../config/environment', __FILE__)
  end

  def parse_options(argv)
    argv[0] = '--help' unless argv[0]
    @options = {}
    OptionParser.new do |opts|
      opts.banner = <<-USAGE
Description:
  Manage the authorization tokens for a user.  In all commands, the --user (-u) flag
  is mandatory.  The argument is expected to be the database id of the user in question.

Usage:
  #{__FILE__} [options]

Examples:

  List all tokens for user
    #{__FILE__} --user ID --list

  Create token for user
    #{__FILE__} --user ID --create

  Delete token for user
    #{__FILE__} --user ID --delete

Options:
USAGE
      opts.on('-l', '--list', 'List tokens (requires --user flag)') do
        @options[:list] = true
      end
      opts.on('-a', '--list-all', 'List all tokens with users') do
        @options[:listall] = true
      end
      opts.on('-c', '--create', 'Create a token') do
        @options[:create] = true
      end
      opts.on('-d', '--delete TOKEN', 'Delete a token') do |token|
        @options[:delete] = token
      end
      opts.on('-u', '--user USERID', 'User id (from database) - REQUIRED') do |p|
        @options[:user] = p.to_i
      end
    end.parse!(argv)
    raise('the --user flag is mandatory!') unless @options[:user] || @options[:listall]
  end

  def out
    @out ||= STDOUT
  end

  def list_tokens
    out.puts "User: #{user.email}"
    out.puts "Account: #{user.account.name}"
    out.puts 'Tokens:'
    out.puts user.authentication_tokens.map(&:token).join("\n")
  end

  def list_all_tokens
    out.puts 'User'.ljust(100) + 'Token'.ljust(30)
    AuthenticationToken.joins(:user).order(:created_at).select('users.email, authentication_tokens.token').find_each do |t|
      out.puts "#{t.email.to_s.ljust(100)}#{t.token.ljust(30)}"
    end
  end

  def create_token
    t = user.authentication_tokens.build
    t.token = user.generate_token
    user.save!
    out.puts 'Create OK'
    list_tokens
  end

  def delete_token
    if (token = user.authentication_tokens.find_by_token(@options[:delete]))
      token.destroy
      puts 'Delete OK'
      list_tokens
    else
      raise "Can't find token #{@options[:delete]}"
    end
  end

  private

  def user
    @user ||= User.find(@options[:user])
  end
end

Tokens.new.run_from_options(ARGV) if __FILE__.include?($PROGRAM_NAME)