require 'spec_helper'

describe Message do
  let(:vendor) { Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }

  context "when short body is empty" do
    let(:message) { account.messages.build(:short_body => nil) }
    it { should_not be_valid }
  end
  
  context "when short body and url are non-empty" do
    let(:message) { account.messages.build(:short_body => 'body', :url=>'http://what.the') }
    it { message.should_not be_valid }
  end

  context "without an account" do
    let(:message) { Message.new(:short_body => "Hello")}
    subject { message }
    it { should_not be_valid }
  end

  context "sms message" do
    let(:message) { account.messages.build(:short_body => 'short body') }

    subject { message }

    context "when valid" do
      it { should be_valid }
    end

    context "when short body is too long" do
      before { message.short_body = "A"*161 }
      it { should_not be_valid }
    end
  end

  context 'a message with valid recipients attributes' do
    let(:message) { account.messages.build(:short_body => "A"*160, :recipients_attributes => [{:phone => "6515551212", :vendor => vendor}]) }
    it { message.should be_valid }
    it { message.should have(1).recipients }
  end

  context 'a message with invalid recipients attributes' do
    let(:message) { account.messages.build(:short_body => "A"*160, :recipients_attributes => [{:phone => nil, :vendor => vendor}]) }
    it { message.should_not be_valid }
  end

  context "voice message" do
    let(:message) { account.messages.build(:url => 'http://localhost/file.mp3') }

    subject { message }

    context "when valid" do
      it { should be_valid }
    end
  end

  context "an account with voice and sms senders" do
    let(:voice_vendor) { Vendor.create!(:voice=>true, :name => 'voice vendor', :username => 'username', :password => 'secret', :from => 'from', :worker => 'TwilioVoiceWorker') }
    let(:message) { account.messages.create!(:url => 'http://localhost/file.mp3') }
    before do
      account.vendors << voice_vendor
      account.save!
    end
    it "should return correct worker" do
      message.worker.should eq(TwilioVoiceWorker)
    end

    context "with invalid recipient" do
      before {message.create_recipients([{:phone => nil}])}
      specify { message.recipients.first.should_not be_valid }
    end

    context "with valid recipient" do
      before { message.create_recipients([{:phone => "6093433422"}])}
      specify { message.recipients.first.should be_valid }
      specify { message.recipients.first.vendor.should eq(voice_vendor) }
    end
  end


end