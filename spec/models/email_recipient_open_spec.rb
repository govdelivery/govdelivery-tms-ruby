require 'rails_helper'

describe EmailRecipientOpen do
  let(:vendor) { create(:email_vendor) }
  let(:account) { create(:account, email_vendor: vendor) }

  let(:email_message) do
    EmailMessage.new(body: 'short body', subject: 'fuuu').tap do |em|
      em.account = account
      em.save!
    end
  end

  let(:email_recipient) do
    email_message.recipients.build(email: 'ortega_jets@evotest.govdelivery.com').tap(&:save!)
  end

  subject do
    EmailRecipientOpen.new.tap do |ero|
      ero.email_message = email_message
      ero.email_recipient = email_recipient
      ero.email = email_recipient.email
      ero.event_ip = '1.2.3.4'
      ero.opened_at = Time.zone.now
    end
  end

  it { is_expected.to be_valid }

  [:email_message, :email_recipient, :event_ip, :email, :opened_at].each do |attr|
    context "when #{attr} is nil" do
      before do
        subject.send("#{attr}=", nil)
      end
      it { is_expected.to be_invalid }
    end
  end

  it 'should select proper columns for list' do
    subject.save!
    result = email_recipient.email_recipient_opens.indexed.first
    cols     = [:email_recipient_id, :email_message_id, :opened_at, :id]
    not_cols = (EmailRecipientOpen.columns.map(&:name).map(&:to_sym) - cols)

    cols.each do |c|
      assert result.send(c)
    end
    not_cols.each do |c|
      expect { result.send(c) }.to raise_error
    end
  end
end
