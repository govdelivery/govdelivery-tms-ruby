require 'rails_helper'

describe MessagePresenter do

  context 'sms' do
    it "should link to self" do
      @message = build_stubbed(:sms_message)
      pres = MessagePresenter.new @message, view
      pres._links[:self].should       eql(sms_path(@message))
      pres._links[:recipients].should eql(sms_recipients_path(@message))
      pres._links[:failed].should     eql(failed_sms_recipients_path(@message))
      pres._links[:sent].should       eql(sent_sms_recipients_path(@message))
      pres._links[:clicked].should    be_nil
      pres._links[:opened].should     be_nil
    end
  end

  context 'email' do
    it "should link to self" do
      @message = build_stubbed(:email_message)
      pres = MessagePresenter.new @message, view
      pres._links[:self].should       eql(email_path(@message))
      pres._links[:recipients].should eql(email_recipients_path(@message))
      pres._links[:failed].should     eql(failed_email_recipients_path(@message))
      pres._links[:sent].should       eql(sent_email_recipients_path(@message))
      pres._links[:clicked].should    eql(clicked_email_recipients_path(@message))
      pres._links[:opened].should     eql(opened_email_recipients_path(@message))
    end
  end

  context 'voice' do
    it "should link to self" do
      @message = build_stubbed(:voice_message)
      pres = MessagePresenter.new @message, view
      pres._links[:self].should       eql(voice_path(@message))
      pres._links[:recipients].should eql(voice_recipients_path(@message))
      pres._links[:failed].should     eql(failed_voice_recipients_path(@message))
      pres._links[:sent].should       eql(sent_voice_recipients_path(@message))
      pres._links[:clicked].should    be_nil
      pres._links[:opened].should     be_nil
    end
  end

  context 'new record' do
    #this happens when a create fails and we are rendering errors
    it 'should render errors' do
      @message = build(:voice_message)
      pres = MessagePresenter.new @message, view
      pres._links[:self].should       eql( voice_index_path )
      pres._links[:recipients].should be_nil
    end

  end
end
