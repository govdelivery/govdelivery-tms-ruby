require 'rails_helper'

describe Analytics::ProcessBounce do
  subject { Analytics::ProcessBounce.new }

  context 'a recipient' do
    let(:vendor) { create(:email_vendor) }
    let(:account) { create(:account, email_vendor: vendor, name: 'account') }
    let(:email_message) { create(:email_message, account: account) }
    let(:email_recipient) { create(:email_recipient, message: email_message, vendor: vendor) }

    before do
      email_recipient.sending!('ack')
    end
    %w(soft_bounce hard_bounce mail_block).each do |msg_type|
      it 'should respond to a message' do
        message = { 'recipient' => email_recipient.x_tms_recipient,
                    'uri'       => msg_type, # this-bang will get invoked
                    'message'   => 'blows' }
        subject.perform(message)
        expect(email_recipient.reload.failed?).to be true
      end

      it 'should fail on email mismatch' do
        xtr_header = email_recipient.x_tms_recipient
        email_recipient.update_attribute(:email, 'not@me.com')
        message = { 'recipient' => xtr_header,
                    'uri'       => msg_type, # this-bang will get invoked
                    'message'   => 'blows' }
        subject.perform(message)
        expect(email_recipient.reload.failed?).to be false
      end
    end
  end
end
