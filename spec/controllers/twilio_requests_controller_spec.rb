require 'rails_helper'

describe TwilioRequestsController, '#create' do
  render_views
  # a short_code has been provisioned with twilio
  # a vendor has been provisioned with credentials from twilio
  # AccountSid and MessageSid are added to the request by twilio

  # let(:vendor) { create(:sms_vendor) }
  # let(:response_text) { 'a response!' }
  before :each do |_group|
    @vendor = create(:sms_vendor)
  end

  let(:handler) { stub('InboundMessageHandler', vendor: @vendor, response_text: 'yup') }

  it 'should return 404 on a non-existant AccountSid' do
    post :create, twilio_request_params('HELP ', @vendor).merge('AccountSid' => 'something ridiculous')
    expect(response.response_code).to eq(404)
  end

  it 'should return nothing if message handler says so' do
    TwilioRequestsController.any_instance.stubs(:handler).returns(handler)
    handler.expects(:handle).returns(false)
    post :create, twilio_request_params('HELP ', @vendor).merge('AccountSid' => 'valid')
    expect(assigns(:response).response_text).to be nil
    expect(response.response_code).to eq(201)
  end

  it 'should return something if message handler says so' do
    TwilioRequestsController.any_instance.stubs(:handler).returns(handler)
    handler.expects(:handle).returns(true)
    post :create, twilio_request_params('HELP ', @vendor).merge('AccountSid' => 'valid')
    expect(assigns(:response).response_text).to eq 'yup'
    expect(response).to be_a_valid_twilio_sms_response
    expect(response.response_code).to eq(201)
  end


  def twilio_request_params(body, vendor)
    @sid ||= ('0' * 34)
    @sid.succ!
    {format:      'xml',
     'SmsSid'     => @sid,
     'MessageSid' => @sid,
     'AccountSid' => vendor.username,
     'From'       => vendor.username,
     'To'         => vendor.from_phone,
     'Body'       => body}
  end

end
