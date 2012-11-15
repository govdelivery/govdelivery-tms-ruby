require_relative '../../app/models/phone_number'

describe PhoneNumber do
  let(:phone) { PhoneNumber.new(nil) }
  describe "when phone contains local formatting" do
    before { phone.number = '(651) 555-1212 ' }
    it do
      phone.e164.should eq("+16515551212")
      phone.dcm.should eq("1+6515551212")
    end
  end
  describe "when nil" do
    it do
      phone.e164.should be(nil)
      phone.dcm.should be(nil)
    end
  end
  ####################
  describe 'invalid phone numbers' do
    subject { PhoneNumber.new('invalid') }
    its(:number) { should == 'invalid' }
    its(:e164) { should be_nil }
  end
  describe 'valid numbers' do
    subject { PhoneNumber.new('6515551234') }
    its(:e164) { should == '+16515551234' }

    ['(651) 555-1212 ', '1 (651) 555-1212', '+1 (651) 555-1212'].each do |n|
      phone = PhoneNumber.new(n)
      it 'should format correctly' do
        phone.e164.should == '+16515551212'
      end
      it 'should not format number' do
        phone.number.should == n
      end
    end
  end
end
