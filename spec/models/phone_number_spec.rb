require 'spec_helper'
require_relative '../../app/models/phone_number'

describe PhoneNumber do
  describe 'when nil' do
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
  end

  describe 'invalid non-numeric phone numbers' do
    subject { PhoneNumber.new('invalid') }
    its(:number) { should eq 'invalid' }
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
  end

  describe 'invalid numeric phone numbers starting with zero' do
    let(:number) { '0001112222' }
    subject { PhoneNumber.new(number) }
    its(:number) { should eq number }
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
  end

  describe 'invalid numeric phone numbers starting with zero' do
    let(:number) { '1223' }
    subject { PhoneNumber.new(number) }
    its(:number) { should eq number }
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
  end

  describe 'valid UK numbers' do
    subject { PhoneNumber.new('+441604230230') }
    its(:number) { should eq '+441604230230' }
    its(:e164) { should eq '+441604230230' }
    its(:dcm) { should eq '44+1604230230' }
  end
  describe 'valid US numbers' do
    subject { PhoneNumber.new('6515551234') }
    its(:e164) { should == '+16515551234' }
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
