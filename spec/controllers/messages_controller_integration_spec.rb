require 'rails_helper'

describe 'MessageControllers' do
  render_views
  let(:user) {
    voice_vendor = create(:voice_vendor)
    sms_vendor = create(:sms_vendor)
    account = Account.create!(:voice_vendor => voice_vendor, :sms_vendor => sms_vendor, :name => 'name')
    account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop")
  }

  before do
    sign_in user
  end
  describe '#show' do
    # this shared example relies on let() bindings json & message
    shared_examples_for 'a non-new message response' do
      it 'has correct attributes' do
        json.fetch('status').should == message.status
        json['recipient_counts']['total'].should == message.recipients.count
        VoiceRecipient.aasm.states.map(&:to_s).each do |status|
          json['recipient_counts'][status].should == 1
        end
      end
    end

    describe VoiceMessagesController do
      describe 'with no recipients' do
        let(:message) do
          add_recipients!(create_message(:voice))
        end
        let(:json) {
          get :show, :id => message.id
          response.status.should eq(200)
          HashWithIndifferentAccess.new(JSON.parse(response.body))
        }
        it 'has 0 for all recipient_counts' do
          json['recipient_counts']['total'].should == 7
          VoiceRecipient.aasm.states.map(&:to_s).each do |status|
            json['recipient_counts'][status].should == 1
          end
        end
      end
      let(:message) {
        add_recipients!(create_message(:voice))
      }
      let(:json) {
        get :show, :id => message.id
        HashWithIndifferentAccess.new(JSON.parse(response.body))
      }
      it_behaves_like 'a non-new message response'
      it 'has correct voice-specific attributes' do
        json['play_url'].should == message.play_url
        json.should_not include 'body'
        json['_links']['self'].should == "/messages/voice/#{message.id}"
        json['_links']['recipients'].should == "/messages/voice/#{message.id}/recipients"
      end
    end

    describe SmsMessagesController do
      let(:message) {
        add_recipients!(create_message(:sms))
      }
      let(:json) {
        get :show, :id => message.id
        HashWithIndifferentAccess.new(JSON.parse(response.body))
      }
      it_behaves_like 'a non-new message response'
      it 'has correct sms-specific attributes' do
        json['body'].should == message.body
        json.should_not include 'url'
        json['_links']['self'].should == "/messages/sms/#{message.id}"
        json['_links']['recipients'].should == "/messages/sms/#{message.id}/recipients"
      end
    end

    def create_message(message_type)
      if message_type == :sms
        m = user.sms_messages.new(:body => 'A short body')
      elsif message_type == :voice
        m = user.voice_messages.new(:play_url => 'http://foo.com/hello.wav', :max_retries => 2, :retry_delay => 1200)
      end
      m.save!
      m
    end
    def add_recipients!(m)
      VoiceRecipient.aasm.states.map(&:to_s).each_with_index do |status, i|
        attrs = {phone: "555444#{i}111"}
        r = m.recipients.create!(attrs)
        r.update_attribute(:status, status)
      end
      m.ready!
      m
    end
  end
end
