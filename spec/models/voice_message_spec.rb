require 'spec_helper'

describe VoiceMessage do
  let(:vendor) { create(:voice_vendor, worker: 'TwilioVoiceWorker') }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }


  context "a voice message" do
    let(:message) { account.voice_messages.build(:play_url => 'http://localhost/file.mp3') }

    subject { message }
    it { should be_valid }
  end

  context "a voice message with a script" do
    let(:message) { account.voice_messages.create!(:say_text => 'Your Gov Delivery authorization code is 1 2 3 4 5. Thank you for using Gov Delivery. This message will repeat.') }

    subject { message }
    it { subject.call_script.should_not be_nil }
  end

  context "an account with voice and sms senders" do
    let(:message) { account.voice_messages.create!(:play_url => 'http://localhost/file.mp3') }
    before do
      account.save!
    end
    it "should return correct worker" do
      message.worker.should eq(TwilioVoiceWorker)
    end

    context "being marked as sending" do
      before do 
        message.create_recipients([{:phone => "4054343424"}])
        message.expects(:process_blacklist!)
        message.sending!
      end
      specify do
        message.recipients.first.status.should eq(RecipientStatus::SENDING)
        message.recipients.first.status.should_not be_nil
      end
    end
    context "with invalid recipient" do
      before { message.create_recipients([{:phone => nil}]) }
      specify { message.recipients.count.should == 0  }
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
