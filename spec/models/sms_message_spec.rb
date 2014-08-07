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
      before { message.async_recipients = []}
      it 'should be invalid' do
        subject.save_with_async_recipients.should eq(false)
        subject.errors.get(:recipients).should eq(['must contain at least one valid recipient'])
      end
    end

    context 'when recipients list is garbage' do
      before { message.async_recipients = ['dude']}
      it 'should be invalid' do
        subject.save_with_async_recipients.should eq(false)
        subject.errors.get(:recipients).should eq(['must contain at least one valid recipient'])
        subject.async_recipients.should eq([])
      end
    end

    context 'when recipients list is valid' do
      before { message.async_recipients = [{:phone=>'+16125015456'}]}
      it 'should be invalid' do
        subject.save_with_async_recipients.should eq(true)
        subject.async_recipients.should eq([{:phone=>'+16125015456'}])
        subject.recipients.should == []
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
        :body => "FOOO",
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
      shared_message.process_blacklist!
      shared_message.recipients.find_by_phone('6515551212').status.should eq(RecipientStatus::BLACKLISTED)
      shared_message.recipients.find_by_phone('6515551215').status.should eq(RecipientStatus::BLACKLISTED)
      shared_message.recipients.find_by_phone('6515551218').status.should eq(RecipientStatus::NEW)
    end
  end

  context 'a message with blacklisted and legitimate recipients' do
    let(:message) {
      create(:sms_message,
        account: account,
        body: "A"*160,
        recipients_attributes: [{:phone => "6515551212", :vendor => vendor}, {:phone => "6515551215", :vendor => vendor}])
    }
    before do
      vendor.stop_requests.create!(:phone => "+16515551212")
    end
    it 'should be removed' do
      message.blacklisted_recipients.count.should eq(1)
      message.sendable_recipients.count.should eq(1)
      message.process_blacklist!
      message.recipients.find_by_phone('6515551212').status.should eq(RecipientStatus::BLACKLISTED)
      message.recipients.find_by_phone('6515551215').status.should eq(RecipientStatus::NEW)
    end
    context 'and checked for completion' do
      before do
        message.process_blacklist!
        message.recipients.find_by_phone('6515551215').sent!('ack1')
      end
      it 'should change status' do
        message.check_complete!.should eq(true)
        message.status.should eq(SmsMessage::Status::COMPLETED)
      end
    end
  end

  context 'a message with invalid recipients attributes' do
    let(:message) { account.sms_messages.build(:body => "A"*160, :recipients_attributes => [{:phone => nil}]) }
    it { message.should_not be_valid }
  end

end
