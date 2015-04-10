require 'rails_helper'

describe SmsVendor do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { create(:account, sms_vendor: vendor) }
  let(:from) { '+12223334444' }
  subject { vendor }

  describe 'when valid' do
    it { expect(vendor.valid?).to eq(true) }
  end

  it 'should not allow duplicate from fields' do
    v2 = create(:sms_vendor)
    v2.from_phone = vendor.from_phone
    expect(v2).not_to be_valid
  end

  [:name, :username, :password, :from, :shared].each do |field|
    describe "when #{field} is empty" do
      before { vendor.send("#{field}=", nil) }
      it { expect(vendor.valid?).to eq(false) }
    end
  end

  [:name, :username, :password].each do |field|
    describe "when #{field} is too long" do
      before { vendor.send("#{field}=", 'W' * 257) }
      it { expect(vendor.valid?).to eq(false) }
    end
  end

  describe 'a phone number with non-numberic stuff in it' do
    it 'should normalize phone' do
      vendor.from = '(612) 657 8309'
      vendor.save!
      expect(vendor.from).to eq('+16126578309')
    end
    it 'should normalize phone with country code' do
      vendor.from = '+1 (612) 657 8309'
      vendor.save!
      expect(vendor.from).to eq('+16126578309')
    end
    it 'should leave short code alone' do
      vendor.from = '468311'
      vendor.save!
      expect(vendor.from).to eq('468311')
    end
  end

  describe '#create_inbound_message!' do
    it 'creates an inbound message' do
      vendor.stubs(:accounts).returns([])
      expect { vendor.create_inbound_message!(from: from, body: 'msg', keyword: nil) }.to change { vendor.inbound_messages.count }.by 1
    end
  end

  describe '#stop!' do
    it 'creates a stop request and calls stop on all accounts' do
      command_params = CommandParameters.new(from: '+15552223323')
      vendor.stubs(:accounts).returns([mock('account1', stop: true), mock('account1', stop: true)])
      expect do
        vendor.stop!(command_params)
      end.to change { vendor.stop_requests.count }.by 1
    end
  end

  describe '#start!' do
    it 'deletes a stop request' do
      phone = '+15552223323'
      command_parameters = CommandParameters.new(from: phone)
      vendor.stop_requests.create!(phone: phone)
      expect do
        vendor.start!(command_parameters)
      end.to change { vendor.stop_requests.count }.by(-1)
    end
  end
end
