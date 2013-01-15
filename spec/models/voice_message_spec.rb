require 'spec_helper'

describe VoiceMessage do
  let(:vendor) { create_voice_vendor(:worker=>'TwilioVoiceWorker') }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }


  context "a voice message" do
    let(:message) { account.voice_messages.build(:play_url => 'http://localhost/file.mp3') }

    subject { message }
    it { should be_valid }
  end

  context "an account with voice and sms senders" do
    let(:message) { account.voice_messages.create!(:play_url => 'http://localhost/file.mp3') }
    before do
      account.save!
    end
    it "should return correct worker" do
      message.worker.should eq(TwilioVoiceWorker)
    end

    context "with invalid recipient" do
      before { message.create_recipients([{:phone => nil}]) }
      specify { message.recipients.first.should_not be_valid }
    end

    context "with valid recipient" do
      before { message.create_recipients([{:phone => "6093433422"}]) }
      specify { message.recipients.first.should be_valid }
      specify { message.sendable_recipients.first.should be_valid }
      specify { message.should respond_to(:process_blacklist!) }
      specify { message.recipients.first.vendor.should eq(vendor) }
    end
  end
end
