require 'rails_helper'

describe ForwardStopsToDcm do
  let(:shared_number) { '+15554443333' }
  let(:from) { '+15551112222' }
  let(:sid) { 'stub_sid' }
  let(:account_sid) { 'stub_account_sid' }
  let(:expected_params) {
    {
      'To'         => shared_number,
      'From'       => from,
      'MessageSid' => sid,
      'SmsSid'     => sid,
      'AccountSid' => account_sid
    }
  }

  context '.verify_and_forward!' do
    before do
      Rails.stubs(:configuration).returns(stub(shared_phone_numbers: [shared_number]))
    end

    it 'should forward stops to shared numbers' do
      subject.class.expects(:perform_async).with(forward_params: expected_params)
      subject.class.verify_and_forward!('stop', shared_number, from, sid, account_sid)
    end

    it 'should not forward stops to non-shared numbers' do
      subject.class.expects(:perform_async).never
      subject.class.verify_and_forward!('stop', '+15554443388', from, sid, account_sid)
    end

    it 'should not forward not-stops to shared numbers' do
      subject.class.expects(:perform_async).never
      subject.class.verify_and_forward!('dope', shared_number, from, sid, account_sid)
    end
  end

  context '#perform' do
    let(:conn) { mock('Faraday connection') }
    before do
      subject.stubs(:connection).returns(conn)
    end

    it 'always sends "stop" as the body param' do
      Rails.stubs(:configuration).returns(stub(
                                            dcm:                  {api_root: 'a-url'},
                                            shared_phone_numbers: [shared_number]
                                          ))

      conn.expects(:post).with('a-url/api/twilio_requests', has_entry('Body', 'stop'))
      Rails.stubs(:configuration).returns(stub(dcm: {api_root: 'a-url'}, shared_phone_numbers: [shared_number]))
      subject.perform('forward_params' => {'To' => 'mock'})
    end
  end
end
