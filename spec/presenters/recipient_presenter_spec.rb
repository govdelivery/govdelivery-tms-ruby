require 'rails_helper'

describe RecipientPresenter do
  let(:account) { build_stubbed(:account, sid: 'this_is_sid') }
  let(:presenter) { RecipientPresenter.new(recipient, account) }

  context 'sms' do
    let(:recipient) { build_stubbed(:sms_recipient, message_id: 101, status: 'sending') }
    it "should work" do
      presenter.url.should eq(sms_recipient_url(101, recipient))
      presenter.message_url.should eq(sms_url(recipient.message_id))
      presenter.to_webhook.should eq({
                                       message_type:  'sms',
                                       status:        recipient.status,
                                       recipient_url: presenter.url,
                                       message_url:   presenter.message_url,
                                       sid:           'this_is_sid'
                                     })
    end
  end

  context 'sms with error_message and completed_at' do
    let(:recipient) { build_stubbed(:sms_recipient, message_id: 101, completed_at: Time.now, error_message: 'not cool', status: 'failed') }
    it "should work" do
      presenter.url.should eq(sms_recipient_url(101, recipient))
      presenter.message_url.should eq(sms_url(recipient.message_id))
      presenter.to_webhook.should eq({
                                       message_type:  'sms',
                                       status:        recipient.status,
                                       recipient_url: presenter.url,
                                       message_url:   presenter.message_url,
                                       error_message: 'not cool',
                                       completed_at:  recipient.completed_at,
                                       sid:           'this_is_sid'
                                     })
    end
  end

  context 'voice' do
    let(:recipient) { build_stubbed(:voice_recipient, message_id: 102, status: 'sending') }
    it "should work" do
      presenter.url.should eq(voice_recipient_url(102, recipient))
      presenter.message_url.should eq(voice_url(recipient.message_id))
      presenter.to_webhook.should eq({
                                       message_type:  'voice',
                                       status:        recipient.status,
                                       recipient_url: presenter.url,
                                       message_url:   presenter.message_url,
                                       sid:           'this_is_sid'
                                     })
    end
  end

  context 'email' do
    let(:recipient) { build_stubbed(:email_recipient, message_id: 103, status: 'sending') }
    it "should work" do
      presenter.url.should eq(email_recipient_url(103, recipient))
      presenter.message_url.should eq(email_url(recipient.message_id))
      presenter.to_webhook.should eq({
                                       message_type:  'email',
                                       status:        recipient.status,
                                       recipient_url: presenter.url,
                                       message_url:   presenter.message_url,
                                       sid:           'this_is_sid'
                                     })
    end
  end
end
