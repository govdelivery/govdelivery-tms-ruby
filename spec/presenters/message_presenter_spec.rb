require 'rails_helper'

describe MessagePresenter do
  context 'sms' do
    it 'should link to self' do
      @message = build_stubbed(:sms_message)
      pres = MessagePresenter.new @message, view
      expect(pres._links[:self]).to eql(sms_path(@message))
      expect(pres._links[:recipients]).to eql(sms_recipients_path(@message))
      expect(pres._links[:failed]).to eql(failed_sms_recipients_path(@message))
      expect(pres._links[:sent]).to eql(sent_sms_recipients_path(@message))
      expect(pres._links[:clicked]).to be_nil
      expect(pres._links[:opened]).to be_nil
    end
  end

  context 'email' do
    it 'should link to self' do
      @message = build_stubbed(:email_message)
      pres = MessagePresenter.new @message, view
      expect(pres._links[:self]).to eql(email_path(@message))
      expect(pres._links[:recipients]).to eql(email_recipients_path(@message))
      expect(pres._links[:failed]).to eql(failed_email_recipients_path(@message))
      expect(pres._links[:sent]).to eql(sent_email_recipients_path(@message))
      expect(pres._links[:clicked]).to eql(clicked_email_recipients_path(@message))
      expect(pres._links[:opened]).to eql(opened_email_recipients_path(@message))
    end

    context 'with template' do
      it 'should include an email_template link' do
        @email_template = build_stubbed(:email_template)
        @email_template.stubs(:uuid).returns('uuid1234')
        @message = build_stubbed(:email_message, email_template: @email_template)
        pres = MessagePresenter.new @message, view
        expect(pres._links[:self]).to eql(email_path(@message))
        expect(pres._links[:recipients]).to eql(email_recipients_path(@message))
        expect(pres._links[:failed]).to eql(failed_email_recipients_path(@message))
        expect(pres._links[:sent]).to eql(sent_email_recipients_path(@message))
        expect(pres._links[:clicked]).to eql(clicked_email_recipients_path(@message))
        expect(pres._links[:opened]).to eql(opened_email_recipients_path(@message))
        expect(pres._links[:email_template]).to eq(templates_email_path(@email_template))
      end
    end
  end

  context 'voice' do
    it 'should link to self' do
      @message = build_stubbed(:voice_message)
      pres = MessagePresenter.new @message, view
      expect(pres._links[:self]).to eql(voice_path(@message))
      expect(pres._links[:recipients]).to eql(voice_recipients_path(@message))
      expect(pres._links[:failed]).to eql(failed_voice_recipients_path(@message))
      expect(pres._links[:sent]).to eql(sent_voice_recipients_path(@message))
      expect(pres._links[:clicked]).to be_nil
      expect(pres._links[:opened]).to be_nil
    end
  end

  context 'new record' do
    # this happens when a create fails and we are rendering errors
    it 'should render errors' do
      @message = build(:voice_message)
      pres = MessagePresenter.new @message, view
      expect(pres._links[:self]).to eql(voice_index_path)
      expect(pres._links[:recipients]).to be_nil
    end
  end
end
