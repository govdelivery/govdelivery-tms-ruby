require 'spec_helper'

describe SmsMessage do
  let(:vendor) { create_sms_vendor }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }

  context "when short body is empty" do
    let(:message) { account.sms_messages.build(:body => nil) }
    it { should_not be_valid }
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

  context 'a message with invalid recipients attributes' do
    let(:message) { account.sms_messages.build(:body => "A"*160, :recipients_attributes => [{:phone => nil}]) }
    it { message.should_not be_valid }
  end

end