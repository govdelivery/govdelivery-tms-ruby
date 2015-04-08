require 'test/unit'
require 'features/support/xact_support'
require 'colored'
require 'awesome_print'


class StatusCodes < Test::Unit::TestCase

  def test_xact_status_codes
	$bt = Hash.new
	$bt.store(1, Time.new.to_s + "::" + rand(100000).to_s)
	expected_subject = $bt[1]
	link_redirect_works = false
	link_in_email = ''
	expected_link = 'http://govdelivery.com'
	expected_link_prefix = 'http://links.govdelivery.com:81'
	path = 'https://stage-tms.govdelivery.com/messages/email'

	imap_opts = {
	  address:    'imap.gmail.com',
	  port:       993,
	  user_name:  'canari7dd@gmail.com',
	  password:   'govdel01!', 
	  enable_ssl: true
	}
	xact_opts = {
	  user_name:  'cukestage@govdelivery.com',
	  password:   'govdel01',
	  recipient:  'canari7dd@gmail.com'
	}
	  email_body = "This is a test for end to end email delivery. <a href=\\\"#{expected_link}\\\">With a link</a>"
	  
	  xact_helper = XACTHelper.new
	  @response = xact_helper.send_email(xact_opts[:user_name], xact_opts[:password], expected_subject, email_body, xact_opts[:recipient], path)


	  if @response.code.eql? 201
	    puts '"201 message created" response found successfully.'.green
	  else
	    puts @response.code
	    fail '201 message created response code NOT FOUND. Check Gmail to see if the message was created erroneously, or run debugger for further details.'.red
	  end 
  end
end



