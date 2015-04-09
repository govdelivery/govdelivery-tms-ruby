require 'rails_helper'

describe StopRequest do
  let(:vendor) { create(:sms_vendor) }
  let(:stop_request) { vendor.stop_requests.build(phone: '+16666666666').tap { |s| s.account_id = 1 } }
  let(:dup_stop_request) { vendor.stop_requests.build(phone: '+16666666666').tap { |s| s.account_id = 1 } }

  [[:phone, 255]].each do |field, length|
    context "when #{field} is empty" do
      before { stop_request.send("#{field}=", nil) }
      specify { expect(stop_request.valid?).to eq(false) }
    end

    context "when #{field} is too long" do
      before { stop_request.send("#{field}=", '1' * (length + 1)) }
      specify { expect(stop_request.valid?).to eq(false) }
    end

    context "when #{field} is not too long" do
      before { stop_request.send("#{field}=", '1' * (length - 1)) }
      specify { expect(stop_request.valid?).to eq(true) }
    end
  end

  context 'when vendor is empty' do
    before { stop_request.vendor = nil }
    specify { expect(stop_request.valid?).to eq(false) }
  end

  context 'happy path' do
    specify { expect(stop_request.valid?).to eq(true) }
  end

  context 'when unique by phone and vendor and account' do
    before { stop_request.save!; dup_stop_request.account_id += 1 }
    specify { expect(dup_stop_request).to be_valid }
  end
  context 'when not unique by phone and vendor and account' do
    before { stop_request.save! }
    specify { expect(dup_stop_request).to be_invalid }
  end
end
