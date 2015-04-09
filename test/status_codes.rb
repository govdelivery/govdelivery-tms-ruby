require 'test/unit'
require 'features/support/xact_support'
require 'colored'
require 'awesome_print'

class StatusCodes < Test::Unit::TestCase
  def test_xact_status_codes
    bt = {}
    bt.store(1, Time.new.to_s + '::' + rand(100_000).to_s)
    expected_subject = bt[1]
    expected_link = 'http://govdelivery.com'
    path = 'https://stage-tms.govdelivery.com/messages/email'
    email_body = "This is a test for end to end email delivery. <a href=\\\"#{expected_link}\\\">With a link</a>"

    xact_helper = XACTHelper.new
    @response = xact_helper.send_email('cukestage@govdelivery.com', 'govdel01', expected_subject, email_body, 'canari7dd@gmail.com', path)

    if @response.code.eql? 201
      puts '"201 message created" response found successfully.'.green
    else
      puts @response.code
      raise '201 message created response code NOT FOUND. Check Gmail to see if the message was created erroneously, or run debugger for further details.'.red
    end
  end
end
