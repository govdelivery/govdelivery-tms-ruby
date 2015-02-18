require 'rails_helper'

describe VoiceMessage do
  let(:account){ create(:account_with_voice) }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }


  context "a voice message" do
    let(:message) { account.voice_messages.build(:play_url => 'http://localhost/file.mp3') }

    subject { message }
    it { should be_valid }
  end

  context "a voice message with nil retry" do
    let(:message) { account.voice_messages.create(:play_url => 'http://localhost/file.mp3', :max_retries => nil) }

    subject! { message }
    it { subject.max_retries.should == 0 }
  end

  context "a voice message with nil retry_delay" do
    let(:message) { account.voice_messages.create(:play_url => 'http://localhost/file.mp3', :retry_delay => nil) }

    subject! { message }
    it { subject.retry_delay.should == 300 }
  end

  context "a voice message with a script" do
    let(:message) { account.voice_messages.create!(:say_text => 'Your Gov Delivery authorization code is 1 2 3 4 5. Thank you for using Gov Delivery. This message will repeat.') }

    subject { message }
    it { subject.call_script.should_not be_nil }

    context 'recipient filters' do
      {failed: 'error_message', sent: "human"}.each do |type, arg|
        context "with recips who #{type}" do
          before do
            subject.recipients.create!(:phone => '5555555555')

            recip = subject.recipients.reload.first
            recip.send(:"#{type}!", 'ack', nil, arg)
          end
          it { subject.send(:"recipients_who_#{type}").count.should == 1 }
        end
      end
    end
  end

  context "an account with voice and sms senders" do
    let(:message) { account.voice_messages.create!(:play_url => 'http://localhost/file.mp3') }
    before do
      account.save!
    end
    it "should return correct worker" do
      message.worker.should eq(TwilioVoiceWorker)
    end
    it "should return correct from_number" do
      message.from_number.should eq(account.from_number)
    end
    context 'being marked ready' do
      before do
        message.expects(:process_blacklist!)
        message.ready!(nil, [{phone: "4054343424"}]).should be true
      end

      context "being marked as sending" do
        before do
          message.sending!.should be true
        end
        specify do
          message.recipients.first.new?.should be true
        end
      end
    end

    context "with invalid recipient" do
      it 'should blow up' do
        expect { message.ready!([{:phone => nil}]) }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "with valid recipient" do
      before { message.create_recipients([{:phone => "6093433422"}]) }
      specify { message.recipients.first.should be_valid }
      specify { message.sendable_recipients.first.should be_valid }
      specify { message.should respond_to(:process_blacklist!) }
      specify { message.recipients.first.vendor.should eq(account.voice_vendor) }
    end
  end
end
