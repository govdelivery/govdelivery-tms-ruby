require 'rails_helper'

describe RecipientsController do
  let(:vendor) { create(:sms_vendor) }

  let(:account) { create(:account, sms_vendor: vendor, name: 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { user.sms_messages.create(:body => "A"*160) }
  let(:voice_message) { user.voice_messages.create(:play_url => "http://your.mom") }
  let(:recipients) do
    3.times.map { |i| message.recipients.build(:phone => (6125551200 + i).to_s) }
  end
  let(:voice_recipients) do
    3.times.map { |i| voice_message.recipients.create!(:phone => (6125551200 + i).to_s, :status => :sending) }
  end
  let(:email_message) { user.email_messages.create(:subject => "subs", :from_name => 'dude', :body => 'hi') }
  let(:email_recipients) do
    3.times.map { |i| email_message.recipients.build(:email => "dude#{i}@sink.govdelivery.com", :macros =>{"foo" => "paper"}) }
  end

  before do
    sign_in user
    User.any_instance.stubs(:account_sms_messages).returns(stub(:find => message))
    SmsMessage.any_instance.stubs(:id).returns(1)
    User.any_instance.stubs(:account_voice_messages).returns(stub(:find => voice_message))
    VoiceMessage.any_instance.stubs(:id).returns(1)
  end

  [:opened, :clicked].each do |type|
    context "##{type}" do
      it "should work with recipients who #{type}" do
        EmailMessage.any_instance.stubs(:id).returns(1)
        User.any_instance.stubs(:account_email_messages).returns(stub(:find => email_message))
        stub_pagination(email_recipients, 1, 5)
        EmailMessage.any_instance.expects(:"recipients_who_#{type}").returns(stub(:page => email_recipients))
        get type, :email_id => 1, :format => :json
        expect(response.response_code).to eq(200)
        expect(assigns(:page)).to eq(1)
        expect(assigns(:content_attributes)).to match_array([:email, :macros])
        expect(response.headers['Link']).to match(/next/)
        expect(response.headers['Link']).to match(/last/)
      end
    end
  end

  context '#failed' do
    it 'should show a failed send' do
      email_recipients.first.failed!
      get :failed, email_id: email_message.id
      expect(response.status).to eql(200)
      expect(assigns(:recipients).count).to eql(1)
      expect(assigns(:recipients).first.status).to eql('failed')
    end
  end

  context '#sent' do
    it 'should show a successful email send' do
      email_recipients.first.sent! :ack
      get :sent, email_id: email_message.id
      expect(response.status).to eql(200)
      expect(assigns(:recipients).count).to eql(1)
      expect(assigns(:recipients).first.status).to eql('sent')
    end
  end

  context '#index' do
    it 'should work with sms recipients' do
      stub_pagination(recipients, 1, 5)
      SmsMessage.any_instance.expects(:recipients).returns(stub(:page => recipients))
      get :index, :sms_id => 1, :format => :json
      expect(assigns(:page)).to eq(1)
      expect(assigns(:content_attributes)).to match_array([:phone, :formatted_phone])
      expect(response.headers['Link']).to match(/next/)
      expect(response.headers['Link']).to match(/last/)
    end
    it 'should work with voice recipients' do
      VoiceMessage.any_instance.stubs(:id).returns(1)
      User.any_instance.stubs(:account_voice_messages).returns(stub(:find => voice_message))
      stub_pagination(voice_recipients, 1, 5)
      VoiceMessage.any_instance.expects(:recipients).returns(stub(:page => voice_recipients))
      get :index, :voice_id => 1, :format => :json
      expect(assigns(:page)).to eq(1)
      expect(assigns(:content_attributes)).to match_array([:phone, :formatted_phone, :secondary_status, :retries])
      expect(response.headers['Link']).to match(/next/)
      expect(response.headers['Link']).to match(/last/)
    end
    it 'should work with email recipients' do
      EmailMessage.any_instance.stubs(:id).returns(1)
      User.any_instance.stubs(:account_email_messages).returns(stub(:find => email_message))
      stub_pagination(email_recipients, 1, 5)
      EmailMessage.any_instance.expects(:recipients).returns(stub(:page => email_recipients))
      get :index, :email_id => 1, :format => :json
      expect(response.response_code).to eq(200)
      expect(assigns(:page)).to eq(1)
      expect(assigns(:content_attributes)).to match_array([:email, :macros])
      expect(response.headers['Link']).to match(/next/)
      expect(response.headers['Link']).to match(/last/)
    end

  end

  context 'SmsMessage' do

    context '#page' do
      it 'should work' do
        stub_pagination(recipients, 2, 5)
        SmsMessage.any_instance.expects(:recipients).returns(stub(:page => recipients))


        get :index, :sms_id => 1, :format => :json, :page => 2
        expect(assigns(:page)).to eq(2)
        expect(response.headers['Link']).to match(/first/)
        expect(response.headers['Link']).to match(/prev/)
        expect(response.headers['Link']).to match(/next/)
        expect(response.headers['Link']).to match(/last/)
      end
    end

    context '#failed' do
      it 'should show a failed send' do
        recipients.first.failed!
        get :failed, sms_id: message.id
        expect(response.status).to eql(200)
        expect(assigns(:recipients).count).to eq(1)
        expect(assigns(:recipients).first.status).to eql('failed')
      end
    end

    context '#sent' do
      it 'should show a successful email send' do
        recipients.first.sent! :ack
        get :sent, sms_id: message.id
        expect(response.status).to eql(200)
        expect(assigns(:recipients).count).to eq(1)
        expect(assigns(:recipients).first.status).to eql('sent')
      end
    end


    context '#show' do
      it 'should work' do
        stub_pagination(recipients, 2, 5)
        SmsMessage.any_instance.expects(:recipients).returns(stub(:find => stub(:find => recipients.first)))

        get :show, :sms_id => 1, :format => :json, :id=> 2
        expect(response.response_code).to eq(200)
        expect(assigns(:recipient)).not_to be_nil
      end
    end
  end

  context 'VoiceMessage' do

    context '#page' do
      it 'should work' do
        stub_pagination(recipients, 2, 5)
        VoiceMessage.any_instance.expects(:recipients).returns(stub(:page => recipients))


        get :index, :voice_id => 1, :format => :json, :page => 2
        expect(assigns(:page)).to eq(2)
        expect(response.headers['Link']).to match(/first/)
        expect(response.headers['Link']).to match(/prev/)
        expect(response.headers['Link']).to match(/next/)
        expect(response.headers['Link']).to match(/last/)
      end
    end

    context '#failed' do
      it 'should show a failed send' do
        voice_recipients.first.failed!
        get :failed, voice_id: voice_message.id
        expect(response.status).to eql(200)
        expect(assigns(:recipients).count).to eq(1)
        expect(assigns(:recipients).first.status).to eql('failed')
      end
    end

    context '#sent' do
      it 'should show a successful send' do
        voice_recipients.first.sent!('ack', nil, 'human')
        get :sent, voice_id: voice_message.id
        expect(response.status).to eql(200)
        expect(assigns(:recipients).count).to eq(1)
        expect(assigns(:recipients).first.status).to eql('sent')
      end
    end

    context '#human' do
      it 'should show a human send' do
        voice_recipients.first.sent!('ack', nil, 'human')
        get :human, voice_id: voice_message.id
        expect(response.status).to eql(200)
        expect(assigns(:recipients).count).to eq(1)
        expect(assigns(:recipients).first.status).to eql('sent')
        expect(assigns(:recipients).first.secondary_status).to eql('human')
      end
    end

    context '#machine' do
      it 'should show a machine send' do
        voice_recipients.first.sent!(:ack, nil, :machine)
        get :machine, voice_id: voice_message.id
        expect(response.status).to eql(200)
        expect(assigns(:recipients).count).to eq(1)
        expect(assigns(:recipients).first.status).to eql('sent')
        expect(assigns(:recipients).first.secondary_status).to eql('machine')
      end
    end

    context '#busy' do
      it 'should show a busy send' do
        voice_recipients.first.failed!('ack', nil, :busy)
        get :busy, voice_id: voice_message.id
        expect(response.status).to eql(200)
        expect(assigns(:recipients).count).to eq(1)
        expect(assigns(:recipients).first.status).to eql('failed')
        expect(assigns(:recipients).first.secondary_status).to eq('busy')
      end
    end

    context '#no_answer' do
      it 'should show a no_answer send' do
        voice_recipients.first.failed!('ack', nil, :no_answer)
        get :no_answer, voice_id: voice_message.id
        expect(response.status).to eql(200)
        expect(assigns(:recipients).count).to eq(1)
        expect(assigns(:recipients).first.status).to eql('failed')
        expect(assigns(:recipients).first.secondary_status).to eq('no_answer')
      end
    end

    context '#could_not_connect' do
      it 'should show a could_not_connect send' do
        voice_recipients.first.failed!('ack', nil, nil)
        get :could_not_connect, voice_id: voice_message.id
        expect(response.status).to eql(200)
        expect(assigns(:recipients).count).to eq(1)
        expect(assigns(:recipients).first.status).to eql('failed')
      end
    end

    context '#show' do
      it 'should work' do
        stub_pagination(recipients, 2, 5)
        VoiceMessage.any_instance.expects(:recipients).returns(stub(:find => stub(:find => recipients.first)))

        get :show, :voice_id => 1, :format => :json, :id=> 2
        expect(response.response_code).to eq(200)
        expect(assigns(:recipient)).not_to be_nil
      end
    end
  end
end
