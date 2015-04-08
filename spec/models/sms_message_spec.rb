require 'rails_helper'

describe SmsMessage do
  let(:vendor) { create(:sms_vendor) }
  let(:shared_vendor) { create(:shared_sms_vendor) }
  let(:account) { account = vendor.accounts.create!(name: 'name') }
  let(:shared_account) { create(:account_with_sms, :shared, prefix: 'hi', sms_vendor: shared_vendor) }
  let(:other_shared_account) { create(:account_with_sms, :shared, prefix: 'hi-too', sms_vendor: shared_vendor) }
  let(:user) { account.users.create!(email: 'foo@evotest.govdelivery.com', password: "schwoop") }

  context "when short body is empty" do
    let(:message) { account.sms_messages.build(body: nil) }
    it { expect(message).not_to be_valid }
  end

  context "without an account" do
    let(:message) { SmsMessage.new(body: "Hello") }
    subject { message }
    it { is_expected.not_to be_valid }
  end

  context "sms message" do
    let(:message) { account.sms_messages.build(body: 'short body') }

    subject { message }

    context "when valid" do
      it { is_expected.to be_valid }
    end

    context "when short body is too long" do
      before { message.body = "A"*161 }
      it { is_expected.not_to be_valid }
    end

    context 'when recipients list is empty' do
      before { message.async_recipients = [] }
      it 'should be invalid' do
        expect(subject.save_with_async_recipients).to eq(false)
        expect(subject.errors.get(:recipients)).to eq(['must contain at least one valid recipient'])
      end
    end

    context 'when recipients list is garbage' do
      before { message.async_recipients = ['dude'] }
      it 'should be invalid' do
        expect(subject.save_with_async_recipients).to eq(false)
        expect(subject.errors.get(:recipients)).to eq(['must contain at least one valid recipient'])
        expect(subject.async_recipients).to eq([])
      end
    end

    context 'when recipients list is valid' do
      before { message.async_recipients = [{phone: '+16125015456'}] }
      it 'should be invalid' do
        expect(subject.save_with_async_recipients).to eq(true)
        expect(subject.async_recipients).to eq([{phone: '+16125015456'}])
        expect(subject.recipients).to eq([])
      end
    end

    context 'recipient filters' do
      [:failed, :sent].each do |type|
        context "with recips who #{type}" do
          before do
            subject.save!
            subject.recipients.create!(phone: '5555555555')

            recip = subject.recipients.reload.first
            recip.send(:"#{type}!", "http://dudes.com/tyler", DateTime.now)
          end
          it { expect(subject.send(:"recipients_who_#{type}").count).to eq(1) }
        end
      end
    end
  end

  context 'a message with valid recipients attributes' do
    let(:message) { account.sms_messages.build(body: "A"*160, recipients_attributes: [{phone: "6515551212"}]) }
    it { expect(message).to be_valid }
    it { expect(message).to have(1).recipients }
    it { expect(message.worker).to eq(LoopbackMessageWorker) }
  end

  context 'a message on a shared vendor with blacklisted and legit recips' do
    let(:shared_message) do
      shared_account.sms_messages.create!(
        body:                  "FOOO",
        recipients_attributes: [{phone: "6515551212", vendor: shared_vendor},
                                   {phone: "6515551215", vendor: shared_vendor},
                                   {phone: "6515551218", vendor: shared_vendor}])
    end

    before do
      # should be filtered out because it is account-specific stop request
      shared_vendor.stop_requests.create!(phone: '+16515551212', account: shared_account)

      # should be filtered out because it is vendor-wide stop request
      shared_vendor.stop_requests.create!(phone: '+16515551215')

      # should NOT be filtered out because stop request has account id of other account
      shared_vendor.stop_requests.create!(phone: '+16515551218', account: other_shared_account)
    end

    it 'should remove the right recipients' do
      expect(shared_message.blacklisted_recipients.count).to eq(2)
      expect(shared_message.sendable_recipients.count).to eq(1)
      expect(shared_message.ready!).to be true
      expect(shared_message.recipients.find_by_phone('6515551212').blacklisted?).to be true
      expect(shared_message.recipients.find_by_phone('6515551215').blacklisted?).to be true
      expect(shared_message.recipients.find_by_phone('6515551218').new?).to be true
    end
  end

  context 'a message with blacklisted and legitimate recipients' do
    let(:message) {
      create(:sms_message,
             account:               account,
             body:                  "A"*160,
             recipients_attributes: [{phone: "6515551212", vendor: vendor}, {phone: "6515551215", vendor: vendor}])
    }
    before do
      vendor.stop_requests.create!(phone: "+16515551212")
    end

    it 'should start out in new state' do
      expect(message.new?).to be true
    end

    it 'should fail on transition to queued if there are no recipients' do
      message.recipients.destroy_all
      expect { message.ready! }.to raise_error(AASM::InvalidTransition)
    end

    it 'should fail on transition from new to sending unless we are responding to a message' do
      expect { message.sending! }.to raise_error(AASM::InvalidTransition)
      expect(message.responding!).to be true
      expect(message.sending?).to be true
    end

    it 'should fail on responding unelss there are recipients' do
      message.recipients.destroy_all
      expect { message.responding! }.to raise_error(AASM::InvalidTransition)
    end

    it 'should get canceled and set all recipients to cancelled' do
      expect(message.cancel!).to be true
      expect(message.completed_at).to_not be nil
      message.recipients.reload.each do |rcpt|
        expect(rcpt.status).to eq 'canceled'
        expect(rcpt.completed_at).to_not be nil
      end
    end

    context 'a valid ready transition from new to queued' do
      before do
        expect(message.ready!).to be true
      end

      it 'should get canceled and set all recipients to cancelled' do
        expect(message.cancel!).to be true
        expect(message.completed_at).to_not be nil
        message.recipients.reload.each do |rcpt|
          expect(rcpt.status).to eq 'canceled'
          expect(rcpt.completed_at).to_not be nil
        end
      end

      it 'should work' do
        expect(message.queued?).to be true
        expect(message.blacklisted_recipients.count).to eq(1)
        expect(message.sendable_recipients.count).to eq(1)
        expect(message.recipients.find_by_phone('6515551212').blacklisted?).to be true
        expect(message.recipients.find_by_phone('6515551215').new?).to be true
      end

      context 'a valid sending transition from queued to sending' do
        before do
          expect(message.sending!).to be true
        end

        it 'should work' do
          expect(message.sent_at).not_to be_nil
        end

        it 'should not complete transition with an incomplete receipient' do
          #expect{message.complete!}.to raise_error(AASM::InvalidTransition)
          expect(message.complete!).to be false
        end

        context 'a valid complete transition from sending to complete' do
          before do
            message.recipients.find_by_phone('6515551215').sent!('doing stuff!')
            expect(message.complete!).to be true
            expect(message.completed_at).to_not be nil
          end

          it 'should be completed at some time' do
            expect(message.completed_at).not_to be_nil
          end

        end
      end

    end


    context 'and checked for completion' do
      it 'should change status' do
        message.recipients.find_by_phone('6515551215').sent!('ack1')
        expect(message.ready!).to be true
        expect(message.sending!).to be true
        expect(message.complete!).to be true
        expect(message.completed?).to be true
      end
    end
  end

  context 'a message with invalid recipients attributes' do
    let(:message) { account.sms_messages.build(body: "A"*160, recipients_attributes: [{phone: nil}]) }
    it { expect(message).not_to be_valid }
  end

  it 'should have counts for all states in recipient_state_counts' do
    message = account.sms_messages.create!(body: 'short body')
    counts  = message.recipient_counts
    EmailRecipient.aasm.states.map(&:to_s).each do |state|
      expect(counts[state]).to eq 0
    end
    expect(counts['total']).to eq 0
  end

end
