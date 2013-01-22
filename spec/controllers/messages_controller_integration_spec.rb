require File.dirname(__FILE__) + '/../spec_helper'

describe 'MessageControllers' do
  render_views
  let(:user) {
    voice_vendor = VoiceVendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') 
    sms_vendor = SmsVendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') 
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
        RecipientStatus.each do |status|
          json['recipient_counts'][status].should == 1
        end
      end
    end

    describe VoiceMessagesController do
      describe 'with no recipients' do
        let(:message) { create_message(:voice, Message::Status::SENDING) }
        let(:json) {
          get :show, :id => message.id
          HashWithIndifferentAccess.new(JSON.parse(response.body))
        }
        it 'has 0 for all recipient_counts' do
          json['recipient_counts']['total'].should == 0
          RecipientStatus.each do |status|
            json['recipient_counts'][status].should == 0
          end
        end
      end
      let(:message) {
        m = create_message(:voice, Message::Status::SENDING)
        add_recipients!(m)
        m
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
        m = create_message(:sms, Message::Status::SENDING)
        add_recipients!(m)
        m
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

    def create_message(message_type, status)
      if message_type == :sms
        m = user.sms_messages.new(:body => 'A short body')
      elsif message_type == :voice
        m = user.voice_messages.new(:play_url => 'http://foo.com/hello.wav')
      end
      m.status = status
      m.save!
      m
    end
    def add_recipients!(m)
      RecipientStatus.each_with_index do |status, i|
        attrs = {:phone => "555444#{i}111"}
        m.create_recipients([attrs])
        m.recipients.where(attrs).each {|r| r.status = status; r.save!}
      end
    end
  end
end
