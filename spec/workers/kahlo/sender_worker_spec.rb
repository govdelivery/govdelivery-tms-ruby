require 'rails_helper'
require File.expand_path('../../../../app/workers/base', __FILE__)

describe Kahlo::SenderWorker do
  context 'an sms send' do
    let(:vendor) { create(:sms_vendor, worker: 'Mblox::SenderWorker') }
    let(:account) { create(:account, sms_vendor: vendor, name: 'name') }
    let(:user) { account.users.create!(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
    let(:message) { user.sms_messages.create(body: 'A' * 160) }
    let(:recipient) { message.recipients.create(phone: "8181112222") }
    let(:client) { stub('GovDelivery::Kahlo::Client') }

    before do
      subject.class.client = client
    end

    after do
      subject.class.client = nil
    end

    context 'a very happy send' do
      it 'should work' do
        client.expects(:deliver_message).with(recipient.to_kahlo.merge(body: "[test] #{'A'*153}"))
        expect do
          subject.perform(
            message_id:   message.id,
            recipient_id: message.recipients.first.id)
        end.to change { message.recipients.where(ack: 'kahlo').count }.by 1
      end
    end

    context 'a send that succeeds but then fails to update the recipient' do
      it 'should not retry' do
        client.expects(:deliver_message).with(recipient.to_kahlo.merge(body: "[test] #{'A'*153}"))

        ex = ActiveRecord::ConnectionTimeoutError.new('this could be anything')
        subject.class.expects(:sending!).raises(ex)
        subject.class.expects(:delay).returns(mock('DelayedClass', sending!: 'jid'))
        expect do
          subject.perform(
            message_id:   message.id,
            recipient_id: message.recipients.first.id)
        end.to raise_exception(Sidekiq::Retries::Fail)
      end
    end
  end
end
