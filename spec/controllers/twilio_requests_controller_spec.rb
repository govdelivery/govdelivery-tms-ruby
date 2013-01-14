require 'spec_helper'

describe TwilioRequestsController, '#create' do
  let(:vendor) { mock('vendor', :stop_text => nil, :help_text => nil, :keywords => nil, :new_record? => false) }
  let(:username) { 'username' }
  let(:response_text) { 'a response!' }

  it 'should error on an incorrect AccountSid' do
    SmsVendor.expects(:find_by_username!).raises(ActiveRecord::RecordNotFound)
    post :create, twilio_request_params('HELP ')
    response.response_code.should eq(404)
  end
  
  it 'uses an SmsReceiver to get the response text' do
    sms_receiver = mock('sms me!', :respond_to_sms! => response_text, :keywords= => nil)
    SmsReceiver.expects(:new).returns(sms_receiver)
    SmsVendor.expects(:find_by_username!).with(username).returns(vendor)

    twilio_response = View::TwilioRequestResponse.new(vendor, response_text)

    View::TwilioRequestResponse.expects(:new).with(vendor, response_text).returns(twilio_response)

    post :create, twilio_request_params('STOP')
    response.response_code.should eq(201)

    assigns(:response).response_text.should == response_text
  end

  def twilio_request_params(body)
    account_id = username
    @sid ||= ('0'*34)
    @sid.succ!
    {:format =>"xml",
     'SmsSid'=>@sid,
     'AccountSid'=>account_id,
     'From'=>'+15551112222',
     'To'=>'',
     'Body'=>body}
  end
end
