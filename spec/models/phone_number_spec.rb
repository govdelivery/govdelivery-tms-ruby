require 'spec_helper'
require_relative '../../app/models/phone_number'

describe PhoneNumber do
  context 'when nil' do
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
  end

  context 'a short code' do
    subject { PhoneNumber.new('468311') }
    its(:number) { should eq '468311' }
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
    its(:e164_or_short) { should eq '468311' }
  end

  context 'invalid non-numeric phone numbers' do
    subject { PhoneNumber.new('invalid') }
    its(:number) { should eq 'invalid' }
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
    its(:e164_or_short) { should be nil }
  end

  context 'invalid numeric phone numbers starting with zero' do
    let(:number) { '0001112222' }
    subject { PhoneNumber.new(number) }
    its(:number) { should eq number }
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
    its(:e164_or_short) { should be nil }
  end

  context 'invalid numeric phone numbers starting with zero' do
    let(:number) { '1223' }
    subject { PhoneNumber.new(number) }
    its(:number) { should eq number }
    its(:e164) { should be_nil }
    its(:e164_or_short) { should be nil }
    its(:dcm) { should be_nil }
  end

  describe 'valid non-US numbers in e164 format' do
    let(:number) { '+441604230230' }
    subject { PhoneNumber.new(number) }
    its(:number) { should eq number }
    its(:e164) { should eq number }
    its(:dcm) { should eq '44+1604230230' }
    its(:e164_or_short) { should eq number }
  end

  describe 'valid US numbers that omit country code' do
    subject { PhoneNumber.new('6515551234') }
    its(:e164) { should == '+16515551234' }
    its(:e164_or_short) { should == '+16515551234' }
    its(:dcm) { should == '1+6515551234' }
  end

  describe "a US number that omits country code and doesn't happen to start with some other country code" do
    subject { PhoneNumber.new('8885551234') }
    its(:e164) { should == '+18885551234' }
    its(:e164_or_short) { should == '+18885551234' }
    its(:dcm) { should == '1+8885551234' }
  end

  describe 'several different formats' do
    ['(651) 555-1212 ', '1 (651) 555-1212', '+1 (651) 555-1212'].each do |n|
      phone = PhoneNumber.new(n)
      it 'should format correctly' do
        expect(phone.e164).to eq '+16515551212'
        expect(phone.dcm).to eq '1+6515551212'
      end
      it 'should not modify #number' do
        expect(phone.number).to eq n
      end
    end
  end
end
