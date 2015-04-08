require 'rails_helper'

describe SmsRecipient do
  subject {
    vendor  = create(:sms_vendor)
    account = create(:account, name: 'account', sms_vendor: vendor)
    message = create(:sms_message, body: 'short body', account: account)
    create(:sms_recipient, message: message, vendor: vendor)
  }

  it { is_expected.to validate_presence_of :phone } # validates_presence_of :phone

  describe "when phone is not a number" do
    before do
      subject.phone = 'invalid'
      subject.save!
    end
    it { is_expected.to be_valid }
    its(:formatted_phone) { should be_nil }
  end

  describe "when phone starts with zero" do
    before do
      subject.phone = '0001112222'
      subject.save
    end
    it { is_expected.to be_valid }
    its(:formatted_phone) { should be_nil }
  end

  describe "when phone has wrong # of digits" do
    before do
      subject.phone = '223'
      subject.save!
    end
    it { is_expected.to be_valid }
    its(:formatted_phone) { should be nil }
  end

  describe "when phone is a non-string number" do
    before do
      subject.phone = 6125015456
      subject.save!
    end
    it { is_expected.to be_valid }
    its(:formatted_phone) { should eq '+16125015456' }
  end

  describe "when phone is valid" do
    before do
      subject.phone = '6515551212'
    end

    it 'should persist formatted_phone if phone number is valid' do
      subject.save!
      expect(subject.formatted_phone).not_to be_nil
    end

    it 'has an ack that is too long' do
      subject.ack = 'A'*257
      expect(subject).not_to be_valid
    end

    it 'has an error message that is too long' do
      subject.error_message = 'A'*513
      expect(subject).to be_valid
    end
  end

  describe 'timeout_expired' do
    let(:vendor) { create(:sms_vendor) }
    let(:account) { create(:account, sms_vendor: vendor, name: 'account') }
    let(:messages) {
      [1, 2].map { |x|
        message = create(:sms_message, account: account, body: "body #{x}")
        recipient = message.recipients.create!(phone: "1612555123#{x}")
        recipient.sending!('doo')
        message.ready!
        message.sending!
        message
      }
    }
    before do
      messages[0].recipients.update_all(sent_at: 5.hour.ago)
      messages[1].recipients.update_all(sent_at: 3.hours.ago)
    end

    it 'only finds recipients in sending status' do
      expect(SmsRecipient.timeout_expired.all).to eq(messages[0].recipients.all)
      messages.each { |m| m.recipients.update_all(status: 'new') }
      expect(SmsRecipient.timeout_expired.all).to be_empty
    end
  end
end

describe SmsRecipient, 'blacklist scopes' do
  let(:sms_vendor) { create(:shared_sms_vendor) }
  let(:account) { create(:account_with_sms) }
  let(:sms_message) { create(:sms_message, account: account) }

  before do
    # vendor-wide blacklist
    sms_message.recipients.create!(phone: "+16123089081", vendor: sms_vendor)
    create(:stop_request, vendor: sms_vendor, phone: "+16123089081", account_id: nil)

    # account-specific blacklist
    sms_message.recipients.create!(phone: "+16123089082", vendor: sms_vendor)
    create(:stop_request, vendor: sms_vendor, phone: "+16123089082", account_id: account.id)

    # wrong account id - should not be blacklisted
    sms_message.recipients.create!(phone: "+16123089083", vendor: sms_vendor)
    create(:stop_request, vendor: sms_vendor, phone: "+16123089083", account_id: 123)
  end

  it 'should get account_blacklisted' do
    scope = sms_message.recipients.account_blacklisted(sms_vendor.id, account.id)
    expect(scope.count).to eq(2)
    expect(scope.map(&:phone).sort).to eq(["+16123089081", "+16123089082"])
  end

  it 'should get not_account_blacklisted' do
    scope = sms_message.recipients.not_account_blacklisted(sms_vendor.id, account.id)
    expect(scope.count).to eq(1)
    expect(scope.map(&:phone)).to eq(["+16123089083"])
  end
end
