#!/usr/bin/env ruby
require 'optparse'

class CreateUser
  def run_from_options(argv)
    parse_options(argv)
    boot_rails

    if @options[:list]
      list_users
    else
      create_account(@options)
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
Usage:
  #{__FILE__} [options]

Examples:

  List All Users
    #{__FILE__} -l

  Create User
    #{__FILE__} -a 10024 -e "insure@evotest.govdelivery.com" -p "fysucrestondoko" -s 0

Options:
USAGE
      opts.on('-l', '--list', 'List Users') do |p|
        @options[:list] = p.to_s
      end
      opts.on('-a', '--name Account ID') do |p|
        @options[:user_account_id] = p.to_s
      end
      opts.on('-e', '--email Email (username)') do |p|
        @options[:user_email] = p.to_s
      end
      opts.on('-p', '--password Password') do |p|
        @options[:user_password] = p.to_s
      end
      opts.on('-s', '--admin Admin') do |p|
        @options[:user_admin] = p
      end
    end.parse!(argv)
  end

  def out(str)
    puts(str) unless RAILS_ENV == 'test'
  end

  def create_account(_options)
    u = User.new
    u.account_id = @options[:user_account_id]
    u.email = @options[:user_email]
    u.password = @options[:user_password]
    u.admin = @options[:user_admin]

    u.save

    if u.errors.present?
      puts u.errors.messages
    else
      puts 'Created User id: ' + u.id.to_s
      display_user(u)
    end
  end

  def list_users
    puts "User.all\n"
    User.all.each { |u| display_user(u)}
  end

  def display_user(u)
    puts "\tid: " + u.id.to_s + "\n"
    puts "\temail: " + u.email + "\n"
    puts "\taccount_id: " + u.account_id.to_s + "\n"
    puts "\tauth token: " + (u.authentication_tokens.first.try(:token) || '(n/a)') + "\n"
    puts "\tadmin: " + u.admin.to_s + "\n"
    puts "\n"
  end
end

CreateUser.new.run_from_options(ARGV) if __FILE__.include?($PROGRAM_NAME)
