require 'rails_helper'
require File.expand_path('../../../../app/workers/base', __FILE__)

describe Kahlo::InboundWorker do
  let(:client) { stub('client') }
  let(:handler) { stub('handler', callback_id: 'abcd1234', outbound_recipient: '+15551112345', inbound_recipient: '468311', response_text: 'echo') }

  before do
    subject.class.client = client
    subject.handler      = handler
  end
  after do
    subject.class.client = nil
    subject.handler      = nil
  end

  context 'the default handler' do
    before do
      create(:sms_vendor, worker: 'MbloxMessageWorker')
      @kahlo_vendor  = create(:sms_vendor, worker: 'MadeUpMessageWorker')
      subject.handler=nil
    end
    it 'should find the right vendor' do
      expect(subject.handler.vendor_scope.all.find_by_from_phone(@kahlo_vendor.from_phone)).to eq(@kahlo_vendor)
    end
  end

  it 'should deliver a message that merits a response' do
    handler.expects(:handle).returns(true)
    client.expects(:deliver_message).with(callback_id: 'abcd1234', to: '+15551112345', from: '468311', body: Service::SmsBody.annotated('echo'), message_type: 'urgent')
    subject.perform({to: '468311', from: '+15551112345', body: 'yo', id: 'AC12345667'}.stringify_keys)
  end

  it 'should not blow up on messages that i guess are not for us to handle' do
    handler.expects(:handle).raises(ActiveRecord::RecordNotFound)
    client.expects(:deliver_message).never
    expect { subject.perform({to: '468311', from: '+15551112345', body: 'yo', id: 'AC12345667'}.stringify_keys) }.to_not raise_error
  end

  it 'should not deliver a message without response' do
    handler.expects(:handle).returns(false)
    client.expects(:deliver_message).never
    subject.perform({to: '468311', from: '+15551112345', body: 'yo', id: 'AC12345667'}.stringify_keys)
  end

end
