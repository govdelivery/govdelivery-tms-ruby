require 'rails_helper'

RSpec.describe Webhook, :type => :model do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { vendor.accounts.create!(:name => 'name') }

  context 'a webhook for failures' do
    it 'should require event_type' do
      webhook = account.webhooks.create(url: 'http://dudes.ruby')
      webhook.errors[:event_type].should_not be_nil
    end

    context 'that is valid' do
      let(:recipient) { build_stubbed(:sms_recipient, message_id: 101, status: 'failed') }
      subject { account.webhooks.create(url: 'http://dudes.ruby', event_type: 'failed') }
      it 'should save' do
        subject.persisted?.should be true
        subject.job_key.should eq 'dudes.ruby'
      end
      it 'should invoke and enqueue a background job' do
        RecipientPresenter.any_instance.stubs(:to_webhook).returns(webhook: 'fake')
        WebhookWorker.expects(:perform_async).with(url: subject.url, job_key: 'dudes.ruby', params: {webhook: 'fake'})
        subject.invoke(recipient)
      end
    end

    it 'is uncool to specify a bogus event type' do
      webhook = account.webhooks.create(url: 'dudes.ruby', event_type: 'buttered')
      webhook.valid?.should be false
      webhook.errors[:event_type].should_not be_nil
      webhook.errors[:url].should_not be_nil
    end
  end
end
