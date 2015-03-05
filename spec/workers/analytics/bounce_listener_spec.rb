require 'rails_helper'
describe Analytics::BounceListener do
  subject { Analytics::BounceListener.new }

  it 'should have topic' do
    expect(subject.topic).to eq('tms_bounce_channel')
  end

  it 'should have group' do
    expect(subject.group).to eq('xact.bounce_listener')
  end

  context 'a recipient' do
    let(:vendor) { create(:email_vendor) }
    let(:account) { create(:account, email_vendor: vendor, name: 'account') }
    let(:email_message) { create(:email_message, account: account) }
    let(:email_recipient) { create(:email_recipient, message: email_message, vendor: vendor) }

    before do
      email_recipient.sending!('ack')
    end
    %w{soft_bounce hard_bounce mail_block}.each do |msg_type|
      it 'should respond to a message' do
        message = {'recipient' => email_recipient.x_tms_recipient,
                   'uri'       => msg_type, #this-bang will get invoked
                   'message'   => 'blows'}
        subject.on_message(message, 1, 1_000)
        expect(email_recipient.reload.failed?).to be true
      end
    end
  end
end
