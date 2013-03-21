#!/usr/bin/env ruby
require 'optparse'

class CreateUser
  def run_from_options(argv)
    parse_options(argv)
    boot_rails

    create_account(@options)

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
  Create User
    #{__FILE__} -a 10024 -e "insure@evotest.govdelivery.com" -p "fysucrestondoko" -s 0
    
Options:
USAGE
      opts.on("-a", "--name Account ID") do |p|
        @options[:user_account_id] = p.to_s
      end
      opts.on("-e", "--email Email (username)") do |p|
        @options[:user_email] = p.to_s
      end
      opts.on("-p", "--password Password") do |p|
        @options[:user_password] = p.to_s
      end
      opts.on("-s", "--admin Admin") do |p|
        @options[:user_admin] = p
      end
    end.parse!(argv)
  end
    
  def out(str)
    puts(str) unless RAILS_ENV == 'test'
  end

  def create_account(options)

    u = User.new
    u.account_id = @options[:user_account_id]
    u.email = @options[:user_email]
    u.password = @options[:user_password]
    u.admin = @options[:user_admin]

    u.save

    if(u.id)
      puts "Created User id: " + u.id.to_s 
    else
      puts "Cannot create user with: \n"
      puts "\taccount_id: " + @options[:user_account_id].to_s
      puts "\temail: " + @options[:user_email].to_s
      puts "\tpassword: " + @options[:user_password].to_s
      puts "\tadmin: " + @options[:user_admin].to_s
    end

  end

end



if __FILE__ == $0
  CreateUser.new.run_from_options(ARGV)
end

