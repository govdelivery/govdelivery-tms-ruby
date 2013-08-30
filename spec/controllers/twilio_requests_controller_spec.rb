require 'spec_helper'

describe TwilioRequestsController, '#create' do
  let(:vendor) { create(:sms_vendor) }
  let(:response_text) { 'a response!' }

  it 'should error on an incorrect AccountSid' do
    SmsVendor.expects(:find_by_username_and_from_phone!).raises(ActiveRecord::RecordNotFound)
    post :create, twilio_request_params('HELP ')
    response.response_code.should eq(404)
  end

  it 'uses an SmsReceiver to get the response text' do
    sms_receiver = mock('sms me!', :respond_to_sms! => response_text)
    SmsReceiver.expects(:new).returns(sms_receiver)
    SmsVendor.expects(:find_by_username_and_from_phone!).with(vendor.username, vendor.from_phone).returns(vendor)

    twilio_response = View::TwilioRequestResponse.new(vendor, response_text)

    View::TwilioRequestResponse.expects(:new).with(vendor, response_text).returns(twilio_response)

    post :create, twilio_request_params('STOP')
    response.response_code.should eq(201)

    assigns(:response).response_text.should == response_text
  end

  def twilio_request_params(body)
    account_id = vendor.username
    @sid ||= ('0'*34)
    @sid.succ!
    {:format => "xml",
     'SmsSid' => @sid,
     'AccountSid' => vendor.username,
     'From' => vendor.username,
     'To' => vendor.from_phone,
     'Body' => body}
  end
end
