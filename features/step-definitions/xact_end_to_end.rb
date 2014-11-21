#!/usr/bin/env ruby 
#encoding: utf-8

require 'capybara'
require 'capybara/cucumber'
require 'rubygems'
require 'colored'
require 'awesome_print'
require 'mail'
require 'httpi'

Capybara.default_wait_time = 600


def expected_link_prefix
    if ENV['XACT_ENV'] == 'qc'
      expected_link_prefix = 'http://test-links.govdelivery.com:80'
    elsif ENV['XACT_ENV'] == 'integration'
      expected_link_prefix = 'http://test-links.govdelivery.com:80'
    elsif ENV['XACT_ENV'] == 'stage'
      expected_link_prefix = 'http://stage-links.govdelivery.com:80/track'
    elsif ENV['XACT_ENV'] == 'prod'
      expected_link_prefix = 'https://odlinks.govdelivery.com'
    end
end

def imap_opts
    if ENV['XACT_ENV'] == 'qc'
        imap_opts = {
        :address    => 'imap.gmail.com',
        :port       => 993,
        :user_name  => 'canari11dd@gmail.com',
        :password   => 'govdel01!', 
        :enable_ssl => true
      }
    elsif ENV['XACT_ENV'] == 'integration'
      imap_opts = {
        :address    => 'imap.gmail.com',
        :port       => 993,
        :user_name  => 'canari9dd@gmail.com',
        :password   => 'govdel01!', 
        :enable_ssl => true
      } 
    elsif ENV['XACT_ENV'] == 'stage'
      imap_opts = {
        :address    => 'imap.gmail.com',
        :port       => 993,
        :user_name  => 'canari7dd@gmail.com',
        :password   => 'govdel01!', 
        :enable_ssl => true
      }
    elsif ENV['XACT_ENV'] == 'prod'
      imap_opts = {
        :address    => 'imap.gmail.com',
        :port       => 993,
        :user_name  => 'canari8dd@gmail.com',
        :password   => 'govdel01!', 
        :enable_ssl => true
      }
    end  
end  

def xact_opts
    if ENV['XACT_ENV'] == 'qc'
      xact_opts = {
        :user_name  => 'cukeautoqc@govdelivery.com',
        :password   => 'govdel01',
        :recipient  => 'canari11dd@gmail.com'
      }
    elsif ENV['XACT_ENV'] == 'integration'
      xact_opts = {
        :user_name  => 'cukeautoint@govdelivery.com',
        :password   => 'govdel01',
        :recipient  => 'canari9dd@gmail.com'
      }
    elsif ENV['XACT_ENV'] == 'stage'
      xact_opts = {
        :user_name  => 'cukestage@govdelivery.com',
        :password   => 'govdel01',
        :recipient  => 'canari7dd@gmail.com'
      }
    elsif ENV['XACT_ENV'] == 'prod'
      xact_opts = {
        :user_name  => 'CUKEPROD@govdelivery.com',
        :password   => 'GovDel01',
        :recipient  => 'canari8dd@gmail.com'
      }
    end 
end  

def path
    if ENV['XACT_ENV'] == 'qc'
      'https://qc-tms.govdelivery.com/messages/email'
    elsif ENV['XACT_ENV'] == 'integration'
      'https://int-tms.govdelivery.com/messages/email'
    elsif ENV['XACT_ENV'] == 'stage'
      'https://stage-tms.govdelivery.com/messages/email'
    elsif ENV['XACT_ENV'] == 'prod'
      'https://tms.govdelivery.com/messages/email'
    end
end

#globals to generate unique variables
#email
$bt = Hash.new
$bt.store(1, Time.new.to_s + "::" + rand(100000).to_s)
expected_subject = $bt[1]
link_redirect_works = false
link_in_email = ''
expected_link = 'http://govdelivery.com'
#expected_status_code = 201


When /^I POST a new EMAIL message to TMS$/ do
  next if dev_not_live?

  email_body = "This is a test for end to end email delivery. <a href=\\\"#{expected_link}\\\">With a link</a>"
  xact_helper = XACTHelper.new
  xact_helper.send_email(xact_opts[:user_name], xact_opts[:password], expected_subject, email_body, xact_opts[:recipient], path)
end


Then /^I go to Gmail to check for message delivery$/ do
  next if dev_not_live?

  message_list = Hash.new { }

  msg_found = false
  wait_time = 5
  num_iterations = 120 # wait ten minutes if you retry every 5 seconds
  iter = 0

  while (msg_found == false && iter < num_iterations)
    puts "Waiting for #{wait_time} more seconds"
    sleep(wait_time)
    iter += 1

    begin
      puts "Logging into Gmail IMAP looking for subject: #{expected_subject}"

      Mail.defaults do
        retriever_method :imap, imap_opts
      end
       
      emails = Mail.find(:what => :last, :count => 1000, :order => :dsc)
         
      emails.each do |mail|
        mail.parts.map { |p| 
          if p.content_type.include? "text/html"
            #puts "Body: " + p.body.decoded
            message_list[mail.subject] = p.body.decoded
          end   

        }
      end

    rescue Exception => e
      puts "Error interacting with Gmail IMAP (will retry in #{wait_time} seconds): " + e.message
      puts e.backtrace
    ensure
      #imap.logout
      #imap.disconnect
    end

    if message_list[expected_subject]
      msg_found = true
      puts "Message #{expected_subject} found after #{wait_time * iter} seconds".green
      doc = Nokogiri::HTML(message_list[expected_subject])

      if(doc)
        doc.css('a').each do |link|
          # test the link
          link_tester = LinkTester.new
          if(link_tester.test_link(link["href"], expected_link, expected_link_prefix))
            link_redirect_works = true
            link_in_email = link["href"]
            puts "Link #{link["href"]} redirects to #{expected_link}".green
          end
        end
      end
    end
  end # end while

  if msg_found == false
    fail "Message #{expected_subject} was not found in the inbox after #{wait_time * iter} seconds".red
  elsif link_redirect_works == false
    fail "Message #{expected_subject} was found but link #{link_in_email}didn't redirect".red
  end

  cleaner = IMAPCleaner.new
  cleaner.clean_inbox(imap_opts[:address], imap_opts[:port], imap_opts[:enable_ssl], imap_opts[:user_name], imap_opts[:password])
  puts 'Cleaned inbox'.green
end 
