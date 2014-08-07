require 'rails_helper'

describe ExpiredRecipientQuery do
  let(:vendor) { create(:email_vendor) }
  let(:account) { create(:account, email_vendor: vendor, name: 'account') }

  let(:messages) {
    [1, 2].map{|x|
      m = create(:email_message, account: account, body: "body #{x}")
      m.create_recipients([email: "from-message#{x}@example.com"])
      m.sending!(nil)
      m
    }
  }

  describe 'with some recipients sent just over and some just under one minute ago' do
    before do
      # do this in SQL to get as close to boundaries as possible
      # 1 second after it times out
      messages.first.recipients.update_all('sent_at = sysdate - 61/(24*60*60)')
      # 1 second before it times out
      messages.last.recipients.update_all('sent_at = sysdate - 59/(24*60*60)')
    end

    it "returns no recipients if there's no timeout" do
      vendor.update_attribute(:delivery_timeout, nil)
      result = ExpiredRecipientQuery.new(EmailRecipient)
      expect(result).to be_empty
    end

    it 'returns the recipients that are timed out' do
      vendor.update_attribute(:delivery_timeout, 1.minute)

      result = ExpiredRecipientQuery.new(EmailRecipient).map(&:id)
      expected = messages.first.recipients.map(&:id)
      expect(result).to eq(expected)
    end

    it 'only finds recipients in sending status' do
      vendor.update_attribute(:delivery_timeout, 1.minute)

      messages.first.recipients.update_all(status: RecipientStatus::SENT)
      result = ExpiredRecipientQuery.new(EmailRecipient)
      expect(result).to be_empty
    end
  end
end
