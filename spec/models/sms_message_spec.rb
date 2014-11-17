require 'rails_helper'

describe SmsMessage do
  let(:vendor) { create(:sms_vendor) }
  let(:shared_vendor) { create(:shared_sms_vendor) }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }
  let(:shared_account) { create(:account_with_sms, :shared, prefix: 'hi', sms_vendor: shared_vendor) }
  let(:other_shared_account) { create(:account_with_sms, :shared, prefix: 'hi-too', sms_vendor: shared_vendor) }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }

  context "when short body is empty" do
    let(:message) { account.sms_messages.build(:body => nil) }
    it { message.should_not be_valid }
  end

  context "without an account" do
    let(:message) { SmsMessage.new(:body => "Hello") }
    subject { message }
    it { should_not be_valid }
  end

  context "sms message" do
    let(:message) { account.sms_messages.build(:body => 'short body') }

    subject { message }

    context "when valid" do
      it { should be_valid }
    end

    context "when short body is too long" do
      before { message.body = "A"*161 }
      it { should_not be_valid }
    end

    context 'when recipients list is empty' do
      before { message.async_recipients = [] }
      it 'should be invalid' do
        subject.save_with_async_recipients.should eq(false)
        subject.errors.get(:recipients).should eq(['must contain at least one valid recipient'])
      end
    end

    context 'when recipients list is garbage' do
      before { message.async_recipients = ['dude'] }
      it 'should be invalid' do
        subject.save_with_async_recipients.should eq(false)
        subject.errors.get(:recipients).should eq(['must contain at least one valid recipient'])
        subject.async_recipients.should eq([])
      end
    end

    context 'when recipients list is valid' do
      before { message.async_recipients = [{:phone => '+16125015456'}] }
      it 'should be invalid' do
        subject.save_with_async_recipients.should eq(true)
        subject.async_recipients.should eq([{:phone => '+16125015456'}])
        subject.recipients.should == []
      end
    end

    context 'recipient filters' do
      [:failed, :sent].each do |type|
        context "with recips who #{type}" do
          before do
            subject.save!
            subject.recipients.create!(:phone => '5555555555')

            recip = subject.recipients.reload.first
            recip.send(:"#{type}!", "http://dudes.com/tyler", DateTime.now)
          end
          it { subject.send(:"recipients_who_#{type}").count.should == 1 }
        end
      end
    end
  end

  context 'a message with valid recipients attributes' do
    let(:message) { account.sms_messages.build(:body => "A"*160, :recipients_attributes => [{:phone => "6515551212"}]) }
    it { message.should be_valid }
    it { message.should have(1).recipients }
    it { message.worker.should eq(LoopbackMessageWorker) }
  end

  context 'a message on a shared vendor with blacklisted and legit recips' do
    let(:shared_message) do
      shared_account.sms_messages.create!(
        :body                  => "FOOO",
        :recipients_attributes => [{:phone => "6515551212", :vendor => shared_vendor},
                                   {:phone => "6515551215", :vendor => shared_vendor},
                                   {:phone => "6515551218", :vendor => shared_vendor}])
    end

    before do
      # should be filtered out because it is account-specific stop request
      shared_vendor.stop_requests.create!(:phone => '+16515551212', :account => shared_account)

      # should be filtered out because it is vendor-wide stop request
      shared_vendor.stop_requests.create!(:phone => '+16515551215')

      # should NOT be filtered out because stop request has account id of other account
      shared_vendor.stop_requests.create!(:phone => '+16515551218', :account => other_shared_account)
    end

    it 'should remove the right recipients' do
      shared_message.blacklisted_recipients.count.should eq(2)
      shared_message.sendable_recipients.count.should eq(1)
      shared_message.ready!.should be true
      shared_message.recipients.find_by_phone('6515551212').blacklisted?.should be true
      shared_message.recipients.find_by_phone('6515551215').blacklisted?.should be true
      shared_message.recipients.find_by_phone('6515551218').new?.should be true
    end
  end

  context 'a message with blacklisted and legitimate recipients' do
    let(:message) {
      create(:sms_message,
             account:               account,
             body:                  "A"*160,
             recipients_attributes: [{:phone => "6515551212", :vendor => vendor}, {:phone => "6515551215", :vendor => vendor}])
    }
    before do
      vendor.stop_requests.create!(:phone => "+16515551212")
    end

    it 'should start out in new state' do
      message.new?.should be true
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

    context 'a valid ready transition from new to queued' do
      before do
        message.ready!.should be true
      end

      it 'should work' do
        message.queued?.should be true
        message.blacklisted_recipients.count.should eq(1)
        message.sendable_recipients.count.should eq(1)
        message.recipients.find_by_phone('6515551212').blacklisted?.should be true
        message.recipients.find_by_phone('6515551215').new?.should be true
      end

      context 'a valid sending transition from queued to sending' do
        before do
          message.sending!.should be true
        end

        it 'should work' do
          message.sent_at.should_not be_nil
        end

        it 'should not complete transition with an incomplete receipient' do
          #expect{message.complete!}.to raise_error(AASM::InvalidTransition)
          message.complete!.should be false
        end

        context 'a valid complete transition from sending to complete' do
          before do
            message.recipients.find_by_phone('6515551215').sent!('doing stuff!')
            message.complete!.should be true
            expect(message.completed_at).to_not be nil
          end

          it 'should be completed at some time' do
            message.completed_at.should_not be_nil
          end

        end
      end

    end


    context 'and checked for completion' do
      it 'should change status' do
        message.recipients.find_by_phone('6515551215').sent!('ack1')
        message.ready!.should be true
        message.sending!.should be true
        message.complete!.should be true
        message.completed?.should be true
      end
    end
  end

  context 'a message with invalid recipients attributes' do
    let(:message) { account.sms_messages.build(:body => "A"*160, :recipients_attributes => [{:phone => nil}]) }
    it { message.should_not be_valid }
  end

  it 'should have counts for all states in recipient_state_counts' do
    message = account.sms_messages.create!(:body => 'short body')
    counts = message.recipient_counts
    EmailRecipient.aasm.states.map(&:to_s).each do |state|
      expect(counts[state]).to eq 0
    end
    expect(counts['total']).to eq 0
  end

end
