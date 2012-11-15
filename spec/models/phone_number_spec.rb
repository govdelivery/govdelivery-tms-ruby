require 'spec_helper'

describe Message do
  let(:phone) { PhoneNumber.new(nil) }
  context "when phone contains local formatting" do
    before { phone.number = '(651) 555-1212 ' }
    specify {
      phone.e164.should eq("+16515551212")
      phone.dcm.should eq("1+6515551212")
    }
  end
  context "when nil" do
    specify do
      phone.e164.should be(nil)
      phone.dcm.should be(nil)
    end
  end
end