require 'spec_helper'

describe SmsMessage do
  let(:vendor) { create_sms_vendor }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }
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
  end

  context 'a message with valid recipients attributes' do
    let(:message) { account.sms_messages.build(:body => "A"*160, :recipients_attributes => [{:phone => "6515551212"}]) }
    it { message.should be_valid }
    it { message.should have(1).recipients }
    it {message.worker.should eq(LoopbackMessageWorker) }
  end

  context 'a message with blacklisted and legitimate recipients' do
    let(:message) { account.sms_messages.create!(:body => "A"*160, :recipients_attributes => [{:phone => "6515551212"}, {:phone => "6515551215"}]) }
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
