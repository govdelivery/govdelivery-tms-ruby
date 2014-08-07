require 'rails_helper'

describe Twilio::SmsPollingWorker do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:sms_recipients) do
    sms_r1 = stub('SmsRecipient 1',
                  status: 'sent',
                  vendor: vendor,
                  ack: 'sid1',
                  sent_at: 12.hours.ago,
                  completed_at: nil)
    sms_r1.expects(:sent!).with('sid1', 'Mon, 04 Feb 2011 12:07:07 -0600')

    sms_r2 = stub('SmsRecipient 2',
                  status: 'sending',
                  ack: 'sid2',
                  vendor: vendor,
                  sent_at: 12.hours.ago,
                  completed_at: nil)
    sms_r2.expects(:sending!).with('sid2', nil)

    sms_r3 = stub('SmsRecipient 3',
                  status: 'queued',
                  ack: 'sid3',
                  vendor: vendor,
                  sent_at: 12.hours.ago,
                  completed_at: nil)
    [sms_r1, sms_r3, sms_r2]
  end

  let(:twilio_client) do
    client = stub('twilio_client')
    client.expects(:get).with('sid1').returns(
                                              stub('recipient 1',
                                                   sid: 'sid1',
                                                   status: 'sent',
                                                   date_sent: "Mon, 04 Feb 2011 12:07:07 -0600"))
    client.expects(:get).with('sid2').returns(
                                              stub('recipient 1',
                                                   sid: 'sid2',
                                                   status: 'sending',
                                                   date_sent: nil
                                                   ))
    client.expects(:get).with('sid3').raises(Twilio::REST::RequestError, 'whoops')
    client
  end

  let(:finder) do
    f = stub('finder')
    f.expects(:find_each).multiple_yields(*sms_recipients)
    f
  end

  subject do
    worker = Twilio::SmsPollingWorker.new
    worker.stubs(:get_client).returns(twilio_client)
    worker
  end

  it 'should perform happily' do
    SmsRecipient.expects(:to_poll).returns(finder)
    subject.perform
  end
end
