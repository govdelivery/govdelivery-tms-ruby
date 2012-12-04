require_relative '../../app/models/phone_number'

describe PhoneNumber do
  describe 'when nil' do
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
  end
  describe 'invalid phone numbers' do
    subject { PhoneNumber.new('invalid') }
    its(:number) { should == 'invalid' }
    its(:e164) { should be_nil }
    its(:dcm) { should be_nil }
  end
  describe 'valid numbers' do
    subject { PhoneNumber.new('6515551234') }
    its(:e164) { should == '+16515551234' }
  end
  describe 'several different formats' do
    ['(651) 555-1212 ', '1 (651) 555-1212', '+1 (651) 555-1212'].each do |n|
      phone = PhoneNumber.new(n)
      it 'should format correctly' do
        phone.e164.should == '+16515551212'
        phone.dcm.should == '1+6515551212'
      end
      it 'should not modify #number' do
        phone.number.should == n
      end
    end
  end
end
