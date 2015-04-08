require 'rails_helper'

RSpec.describe Webhook, :type => :model do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { vendor.accounts.create!(:name => 'name') }

  context 'a webhook for failures' do
    it 'should require event_type' do
      webhook = account.webhooks.create(url: 'http://dudes.ruby')
      expect(webhook.errors[:event_type]).not_to be_nil
    end

    context 'that is valid' do
      let(:recipient) { build_stubbed(:sms_recipient, message_id: 101, status: 'failed') }
      subject { account.webhooks.create(url: 'http://dudes.ruby', event_type: 'failed') }
      it 'should save' do
        expect(subject.persisted?).to be true
        expect(subject.job_key).to eq 'dudes.ruby'
      end
      it 'should invoke and enqueue a background job' do
        RecipientPresenter.any_instance.stubs(:to_webhook).returns(webhook: 'fake')
        WebhookWorker.expects(:perform_async).with(url: subject.url, job_key: 'dudes.ruby', params: {webhook: 'fake'})
        subject.invoke(recipient)
      end
    end

    it 'is uncool to specify a bogus event type' do
      webhook = account.webhooks.create(url: 'dudes.ruby', event_type: 'buttered')
      expect(webhook.valid?).to be false
      expect(webhook.errors[:event_type]).not_to be_nil
      expect(webhook.errors[:url]).not_to be_nil
    end
  end
end
