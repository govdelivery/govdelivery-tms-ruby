require 'rails_helper'

describe 'MessageControllers' do
  describe SmsMessagesController do
    render_views
    let(:user) do
      sms_vendor = create(:sms_vendor)
      account = Account.create!(sms_vendor: sms_vendor, name: 'name')
      account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')
    end

    before do
      sign_in user
    end
    describe '#show' do
      # this shared example relies on let() bindings json & message
      shared_examples_for 'a non-new message response' do
        it 'has correct attributes' do
          expect(json.fetch('status')).to eq(message.status)
          expect(json['recipient_counts']['total']).to eq(message.recipients.count)
          VoiceRecipient.aasm.states.map(&:to_s).each do |status|
            expect(json['recipient_counts'][status]).to eq(1)
          end
        end
      end

      let(:message) do
        add_recipients!(create_message(:sms))
      end
      let(:json) do
        get :show, id: message.id
        HashWithIndifferentAccess.new(JSON.parse(response.body))
      end
      it_behaves_like 'a non-new message response'
      it 'has correct sms-specific attributes' do
        expect(json['body']).to eq(message.body)
        expect(json).not_to include 'url'
        expect(json['_links']['self']).to eq("/messages/sms/#{message.id}")
        expect(json['_links']['recipients']).to eq("/messages/sms/#{message.id}/recipients")
      end
    end
  end
  describe VoiceMessagesController do
    render_views
    let(:user) do
      account = create(:account_with_voice)
      account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')
    end

    before do
      sign_in user
    end
    describe '#show' do
      # this shared example relies on let() bindings json & message
      shared_examples_for 'a non-new message response' do
        it 'has correct attributes' do
          expect(json.fetch('status')).to eq(message.status)
          expect(json['recipient_counts']['total']).to eq(message.recipients.count)
          VoiceRecipient.aasm.states.map(&:to_s).each do |status|
            expect(json['recipient_counts'][status]).to eq(1)
          end
        end
      end

      describe 'with no recipients' do
        let(:message) do
          add_recipients!(create_message(:voice))
        end
        let(:json) do
          get :show, id: message.id
          expect(response.status).to eq(200)
          HashWithIndifferentAccess.new(JSON.parse(response.body))
        end
        it 'has 0 for all recipient_counts' do
          expect(json['recipient_counts']['total']).to eq(7)
          VoiceRecipient.aasm.states.map(&:to_s).each do |status|
            expect(json['recipient_counts'][status]).to eq(1)
          end
        end
      end
      let(:message) do
        add_recipients!(create_message(:voice))
      end
      let(:json) do
        get :show, id: message.id
        HashWithIndifferentAccess.new(JSON.parse(response.body))
      end
      it_behaves_like 'a non-new message response'
      it 'has correct voice-specific attributes' do
        expect(json['play_url']).to eq(message.play_url)
        expect(json).not_to include 'body'
        expect(json['_links']['self']).to eq("/messages/voice/#{message.id}")
        expect(json['_links']['recipients']).to eq("/messages/voice/#{message.id}/recipients")
      end
    end
  end
  def create_message(message_type)
    if message_type == :sms
      m = user.sms_messages.new(body: 'A short body')
    elsif message_type == :voice
      m = user.voice_messages.new(play_url: 'http://foo.com/hello.wav')
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
