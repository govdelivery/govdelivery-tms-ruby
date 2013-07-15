require 'spec_helper'

describe RecipientsController do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { user.sms_messages.create(:body => "A"*160) }
  let(:voice_message) { user.voice_messages.create(:play_url => "http://your.mom") }
  let(:recipients) do
    3.times.map { |i| message.recipients.build(:phone => (6125551200 + i).to_s) }
  end
  let(:voice_recipients) do
      3.times.map { |i| voice_message.recipients.build(:phone => (6125551200 + i).to_s) }
  end
  let(:email_message) { user.email_messages.create(:subject => "subs", :from_name => 'dude', :body => 'hi') }
  let(:email_recipients) do
    3.times.map { |i| email_message.recipients.build(:email => "dude#{i}@sink.govdelivery.com", :macros =>{"foo" => "paper"}) }
  end

  before do
    sign_in user
    User.any_instance.stubs(:account_sms_messages).returns(stub(:find => message))
    SmsMessage.any_instance.stubs(:id).returns(1)
  end

  [:opened, :clicked].each do |type|
    context "##{type}" do
      it "should work with recipients who #{type}" do
        EmailMessage.any_instance.stubs(:id).returns(1)
        User.any_instance.stubs(:account_email_messages).returns(stub(:find => email_message))
        stub_pagination(email_recipients, 1, 5)
        EmailMessage.any_instance.expects(:"recipients_who_#{type}").returns(stub(:page => email_recipients))
        get type, :email_id => 1, :format => :json
        response.response_code.should == 200
        assigns(:page).should eq(1)
        assigns(:content_attributes).should match_array([:email, :macros])
        response.headers['Link'].should =~ /next/
        response.headers['Link'].should =~ /last/ 
      end
    end
  end

  context '#index' do
    it 'should work with sms recipients' do
      stub_pagination(recipients, 1, 5)
      SmsMessage.any_instance.expects(:recipients).returns(stub(:page => recipients))
      get :index, :sms_id => 1, :format => :json
      assigns(:page).should eq(1)
      assigns(:content_attributes).should match_array([:phone, :formatted_phone])
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end
    it 'should work with voice recipients' do
      VoiceMessage.any_instance.stubs(:id).returns(1)
      User.any_instance.stubs(:account_voice_messages).returns(stub(:find => voice_message))
      stub_pagination(voice_recipients, 1, 5)
      VoiceMessage.any_instance.expects(:recipients).returns(stub(:page => voice_recipients))
      get :index, :voice_id => 1, :format => :json
      assigns(:page).should eq(1)
      assigns(:content_attributes).should match_array([:phone, :formatted_phone])
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end
    it 'should work with email recipients' do
      EmailMessage.any_instance.stubs(:id).returns(1)
      User.any_instance.stubs(:account_email_messages).returns(stub(:find => email_message))
      stub_pagination(email_recipients, 1, 5)
      EmailMessage.any_instance.expects(:recipients).returns(stub(:page => email_recipients))
      get :index, :email_id => 1, :format => :json
      response.response_code.should == 200
      assigns(:page).should eq(1)
      assigns(:content_attributes).should match_array([:email, :macros])
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end

  end

  context '#page' do
    it 'should work' do
      stub_pagination(recipients, 2, 5)
      SmsMessage.any_instance.expects(:recipients).returns(stub(:page => recipients))


      get :index, :sms_id => 1, :format => :json, :page => 2
      assigns(:page).should eq(2)
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end
  end

  context '#show' do
    it 'should work' do
      stub_pagination(recipients, 2, 5)
      SmsMessage.any_instance.expects(:recipients).returns(stub(:find => stub(:find => recipients.first)))

      get :show, :sms_id => 1, :format => :json, :id=> 2
      response.response_code.should == 200
      assigns(:recipient).should_not be_nil
    end
  end

  def stub_pagination(collection, current_page, total_pages)
    collection.stubs(:current_page).returns(current_page)
    collection.stubs(:total_pages).returns(total_pages)
    collection.stubs(:first_page?).returns(current_page == 1)
    collection.stubs(:last_page?).returns(current_page == total_pages)

  end


end
